# 🏗️ Arquitectura del Sistema Pokémon

Este documento detalla la estructura, flujo de datos y modelo relacional del **Sistema Pokémon**.

---

## 🌟 Tecnologías Utilizadas

- **Frontend**: Flutter 3.x (Lenguaje Dart) - Multiplataforma (Web, Windows Desktop, Android, iOS).
- **Backend**: Laravel (PHP 8.2+) - API REST estructurada con Eloquent ORM.
- **Base de Datos**: PostgreSQL 16.
- **Containerización**: Docker & Docker Compose.
- **API Externa**: [PokéAPI](https://pokeapi.co/).
- **Control de Versiones**: Git (`main` y `staging`).

---

## 📁 Estructura de Directorios

```text
sistema_pokemon/
├── back/                           # Backend Laravel
│   ├── app/
│   │   ├── Http/Controllers/       # PokemonController.php (Lógica de endpoints)
│   │   └── Models/                 # Modelos Eloquent: Categoria, Habilidad, Pokemon, PokeFavorito
│   ├── database/migrations/        # Migraciones de PostgreSQL
│   ├── routes/api.php              # Definición de rutas REST
│   └── composer.json
│
├── front/                          # Frontend Flutter
│   ├── lib/
│   │   ├── models/                 # Modelos de datos (PokemonModel)
│   │   ├── screens/                # Pantallas (HomeScreen, FavoritesScreen, PokemonDetailScreen)
│   │   ├── services/               # Clientes HTTP (PokeApiService, BackendApiService)
│   │   ├── theme/                  # Colores por tipo y tema oscuro
│   │   ├── widgets/                # Componentes reutilizables (PokemonCard)
│   │   └── main.dart               # Punto de entrada de la aplicación
│   └── pubspec.yaml
│
├── docker/                         # Configuración de Docker
│   ├── Dockerfile                  # Imagen PHP con extensiones PostgreSQL
│   └── docker-compose.yml
│
├── documentacion/                  # Guías de arquitectura, API y despliegue
│   ├── arquitectura.md
│   ├── endpoints_api.md
│   └── guia_instalacion.md
│
├── docker-compose.yml              # Compose principal para levantar backend y BD
├── .gitignore                      # Reglas de exclusión para Git
└── README.md
```

---

## 🔄 Flujo de Datos

```mermaid
sequenceDiagram
    autonumber
    actor Usuario
    participant Flutter as App Flutter (Frontend)
    participant PokeAPI as PokéAPI Externa
    participant Laravel as Backend Laravel (API)
    participant Postgres as BD PostgreSQL

    Note over Usuario,Flutter: 1. Explorar Pokémon
    Usuario->>Flutter: Abre la aplicación
    Flutter->>PokeAPI: GET https://pokeapi.co/api/v2/pokemon
    PokeAPI-->>Flutter: Lista y detalles de Pokémon (JSON)
    Flutter->>Laravel: GET /api/consultar_pokemon
    Laravel->>Postgres: SELECT * FROM poke_favorito ...
    Postgres-->>Laravel: Registros de favoritos
    Laravel-->>Flutter: Lista de IDs favoritos
    Flutter-->>Usuario: Muestra Pokédex con indicadores de favoritos (❤️)

    Note over Usuario,Postgres: 2. Guardar en Favoritos
    Usuario->>Flutter: Toca el icono de Favorito ❤️
    Flutter->>Laravel: POST /api/guardar_pokemon (Datos del Pokémon)
    Laravel->>Postgres: Inserta/Actualiza Categoria, Habilidad, Pokemon y Favorito
    Postgres-->>Laravel: Confirmación de guardado
    Laravel-->>Flutter: 201 Created (Éxito)
    Flutter-->>Usuario: Feedback visual instantáneo

    Note over Usuario,Postgres: 3. Eliminar de Favoritos
    Usuario->>Flutter: Toca eliminar favorito
    Flutter->>Laravel: DELETE /api/eliminar_pokemon/{id}
    Laravel->>Postgres: DELETE FROM poke_favorito WHERE poke_id = {id}
    Postgres-->>Laravel: Registro eliminado
    Laravel-->>Flutter: 200 OK
    Flutter-->>Usuario: Actualiza lista de favoritos en tiempo real
```

---

## 🗄️ Modelo Entidad-Relación de Base de Datos

```mermaid
erDiagram
    CATEGORIAS ||--o{ POKEMON : "clasifica"
    POKEMON ||--o{ POKEMON_HABILIDAD : "posee"
    HABILIDADES ||--o{ POKEMON_HABILIDAD : "asignada a"
    POKEMON ||--o{ POKE_FAVORITO : "es favorito"
    CATEGORIAS ||--o{ POKE_FAVORITO : "referencia"
    HABILIDADES ||--o{ POKE_FAVORITO : "referencia"

    CATEGORIAS {
        bigint categoria_id PK
        string nombre_categoria
        timestamp created_at
        timestamp updated_at
    }

    HABILIDADES {
        bigint habilidades_id PK
        string nom_habilidades
        timestamp created_at
        timestamp updated_at
    }

    POKEMON {
        bigint poke_id PK "ID original de PokéAPI"
        string nombre
        bigint categoria_id FK
        decimal altura
        decimal peso
        string imagen_url
        timestamp created_at
        timestamp updated_at
    }

    POKEMON_HABILIDAD {
        bigint id PK
        bigint poke_id FK
        bigint habilidades_id FK
    }

    POKE_FAVORITO {
        bigint favo_id PK
        bigint poke_id FK
        bigint categoria_id FK
        bigint habilidades_id FK
        timestamp created_at
        timestamp updated_at
    }
```
