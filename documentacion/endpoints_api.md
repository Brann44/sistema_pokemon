# 🔌 Documentación de Endpoints de la API REST (Laravel)

Base URL por defecto: `http://localhost:8000/api`

---

## 1. Guardar Pokémon en Favoritos

* **Ruta:** `/guardar_pokemon`
* **Método:** `POST`
* **Descripción:** Recibe los datos del Pokémon (obtenidos desde PokéAPI), los registra/actualiza en las tablas `categorias`, `habilidades`, `pokemon` y crea la relación en la tabla `poke_favorito`.

### Request Body (JSON):
```json
{
  "poke_id": 25,
  "nombre": "pikachu",
  "categoria": "electric",
  "altura": 0.4,
  "peso": 6.0,
  "imagen_url": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
  "habilidades": [
    "static",
    "lightning-rod"
  ]
}
```

### Response Exitosa (`201 Created`):
```json
{
  "success": true,
  "message": "¡Pokémon guardado en favoritos con éxito!",
  "data": {
    "favorito_id": 1,
    "pokemon": {
      "poke_id": 25,
      "nombre": "pikachu",
      "categoria_id": 1,
      "altura": 0.4,
      "peso": 6.0,
      "imagen_url": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
      "categoria": {
        "categoria_id": 1,
        "nombre_categoria": "electric"
      },
      "habilidades": [
        {
          "habilidades_id": 1,
          "nom_habilidades": "static"
        },
        {
          "habilidades_id": 2,
          "nom_habilidades": "lightning-rod"
        }
      ]
    }
  }
}
```

---

## 2. Consultar Lista de Favoritos

* **Ruta:** `/consultar_pokemon`
* **Método:** `GET`
* **Descripción:** Devuelve la lista completa de Pokémon registrados como favoritos en PostgreSQL, incluyendo su categoría y lista de habilidades.

### Response Exitosa (`200 OK`):
```json
{
  "success": true,
  "total": 1,
  "data": [
    {
      "favo_id": 1,
      "poke_id": 25,
      "nombre": "pikachu",
      "altura": 0.4,
      "peso": 6.0,
      "imagen_url": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/25.png",
      "categoria": "electric",
      "habilidades": [
        "static",
        "lightning-rod"
      ],
      "guardado_en": "2026-08-21T19:35:00+00:00"
    }
  ]
}
```

---

## 3. Eliminar Pokémon de Favoritos

* **Ruta:** `/eliminar_pokemon/{id}`
* **Método:** `DELETE`
* **Parámetros URL:** `{id}` puede ser el `poke_id` (ID de Pokémon) o el `favo_id` (ID del registro en favoritos).
* **Descripción:** Elimina el registro de la tabla `poke_favorito`.

### Response Exitosa (`200 OK`):
```json
{
  "success": true,
  "message": "Pokémon eliminado de favoritos correctamente."
}
```

### Response Error (`404 Not Found`):
```json
{
  "success": false,
  "message": "El Pokémon no se encuentra en la lista de favoritos."
}
```
