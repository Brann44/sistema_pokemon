<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pokemon;
use App\Models\Categoria;
use App\Models\Habilidad;
use App\Models\PokeFavorito;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class PokemonController extends Controller
{
    /**
     * POST api/guardar_pokemon
     * Guarda o actualiza un Pokémon y lo marca en la lista de favoritos.
     */
    public function guardar_pokemon(Request $request)
    {
        $input = $request->isJson() ? $request->json()->all() : $request->all();
        if (empty($input)) {
            $input = json_decode($request->getContent(), true) ?? [];
        }

        $validator = Validator::make($input, [
            'poke_id' => 'required|integer',
            'nombre' => 'required|string|max:100',
            'categoria' => 'nullable|string|max:100',
            'altura' => 'nullable|numeric',
            'peso' => 'nullable|numeric',
            'imagen_url' => 'nullable|string|max:500',
            'habilidades' => 'nullable|array',
            'habilidades.*' => 'string|max:100',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Errores de validación',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            DB::beginTransaction();

            // 1. Guardar o buscar la Categoría
            $categoriaModel = null;
            $catName = $input['categoria'] ?? null;
            if (!empty($catName)) {
                $categoriaModel = Categoria::firstOrCreate([
                    'nombre_categoria' => strtolower(trim($catName))
                ]);
            }

            // 2. Guardar o actualizar el Pokémon
            $pokemon = Pokemon::updateOrCreate(
                ['poke_id' => $input['poke_id']],
                [
                    'nombre' => strtolower(trim($input['nombre'])),
                    'categoria_id' => $categoriaModel ? $categoriaModel->categoria_id : null,
                    'altura' => $input['altura'] ?? 0,
                    'peso' => $input['peso'] ?? 0,
                    'imagen_url' => $input['imagen_url'] ?? null,
                ]
            );

            // 3. Procesar Habilidades y asociarlas
            $habilidadPrincipalId = null;
            if (!empty($input['habilidades']) && is_array($input['habilidades'])) {
                $habilidadIds = [];
                foreach ($input['habilidades'] as $nomHab) {
                    if (!empty($nomHab)) {
                        $habModel = Habilidad::firstOrCreate([
                            'nom_habilidades' => strtolower(trim($nomHab))
                        ]);
                        $habilidadIds[] = $habModel->habilidades_id;
                        if (!$habilidadPrincipalId) {
                            $habilidadPrincipalId = $habModel->habilidades_id;
                        }
                    }
                }
                $pokemon->habilidades()->sync($habilidadIds);
            }

            // 4. Guardar en la tabla poke_favorito si no existe ya
            $favorito = PokeFavorito::firstOrCreate(
                ['poke_id' => $pokemon->poke_id],
                [
                    'categoria_id' => $categoriaModel ? $categoriaModel->categoria_id : null,
                    'habilidades_id' => $habilidadPrincipalId,
                ]
            );

            DB::commit();

            // Cargar relaciones para devolver el objeto completo
            $pokemon->load(['categoria', 'habilidades']);

            return response()->json([
                'success' => true,
                'message' => '¡Pokémon guardado en favoritos con éxito!',
                'data' => [
                    'favorito_id' => $favorito->favo_id,
                    'pokemon' => $pokemon
                ]
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Error al guardar el Pokémon: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * GET api/consultar_pokemon
     * Retorna la lista completa de Pokémon favoritos con sus detalles, categoría y habilidades.
     */
    public function consultar_pokemon()
    {
        try {
            $favoritos = PokeFavorito::with([
                'pokemon.categoria',
                'pokemon.habilidades',
                'categoria',
                'habilidad'
            ])
            ->orderBy('created_at', 'desc')
            ->get();

            // Formatear respuesta limpia para el frontend
            $resultado = $favoritos->map(function ($fav) {
                return [
                    'favo_id' => $fav->favo_id,
                    'poke_id' => $fav->poke_id,
                    'nombre' => $fav->pokemon ? $fav->pokemon->nombre : 'Desconocido',
                    'altura' => $fav->pokemon ? $fav->pokemon->altura : 0,
                    'peso' => $fav->pokemon ? $fav->pokemon->peso : 0,
                    'imagen_url' => $fav->pokemon ? $fav->pokemon->imagen_url : null,
                    'categoria' => $fav->pokemon && $fav->pokemon->categoria 
                        ? $fav->pokemon->categoria->nombre_categoria 
                        : ($fav->categoria ? $fav->categoria->nombre_categoria : 'general'),
                    'habilidades' => $fav->pokemon 
                        ? $fav->pokemon->habilidades->pluck('nom_habilidades')->toArray()
                        : ($fav->habilidad ? [$fav->habilidad->nom_habilidades] : []),
                    'guardado_en' => $fav->created_at ? $fav->created_at->toIso8601String() : null,
                ];
            });

            return response()->json([
                'success' => true,
                'total' => $resultado->count(),
                'data' => $resultado
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al consultar favoritos: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * DELETE api/eliminar_pokemon/{id}
     * Elimina un Pokémon de la lista de favoritos por su poke_id o favo_id.
     */
    public function eliminar_pokemon($id)
    {
        try {
            // Buscar por favo_id o por poke_id
            $favorito = PokeFavorito::where('favo_id', $id)
                                    ->orWhere('poke_id', $id)
                                    ->first();

            if (!$favorito) {
                return response()->json([
                    'success' => false,
                    'message' => 'El Pokémon no se encuentra en la lista de favoritos.'
                ], 404);
            }

            $favorito->delete();

            return response()->json([
                'success' => true,
                'message' => 'Pokémon eliminado de favoritos correctamente.'
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error al eliminar el favorito: ' . $e->getMessage()
            ], 500);
        }
    }
}
