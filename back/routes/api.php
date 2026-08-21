<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\PokemonController;

// Rutas de la API de Pokémon y Favoritos
Route::post('/guardar_pokemon', [PokemonController::class, 'guardar_pokemon']);
Route::get('/consultar_pokemon', [PokemonController::class, 'consultar_pokemon']);
Route::delete('/eliminar_pokemon/{id}', [PokemonController::class, 'eliminar_pokemon']);

// Fallback preflight OPTIONS para navegadores web (Flutter Web en Chrome)
Route::options('/{any}', function () {
    return response()->json([], 200, [
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers' => 'Content-Type, Authorization, X-Requested-With, Accept',
    ]);
})->where('any', '.*');
