# ⚡ Sistema Pokémon (Full-Stack)

Sistema integral para explorar Pokémon consumiendo la **PokéAPI** pública y gestionando una colección de **favoritos** persistida en **PostgreSQL** mediante una API REST en **Laravel** y una interfaz interactiva construida en **Flutter**.

---

## 🛠️ Stack Tecnológico

- **Frontend**: [Flutter](https://flutter.dev/) (Dart)
- **Backend**: [Laravel](https://laravel.com/) (PHP 8.3)
- **Base de Datos**: [PostgreSQL 16](https://www.postgresql.org/)
- **Contenedores**: [Docker & Docker Compose](https://www.docker.com/)
- **Control de Versiones**: Git (Ramas `main` y `staging`)
- **API Externa**: [PokéAPI](https://pokeapi.co/)

---

## 📂 Estructura del Proyecto

```text
sistema_pokemon/
├── front/             # Aplicación Frontend en Flutter
├── back/              # API Backend en Laravel
├── docker/            # Dockerfile y configuraciones de entorno
├── documentacion/     # Guías de arquitectura, API e instalación
├── docker-compose.yml # Orquestación de contenedores (Laravel + PostgreSQL)
└── README.md
```

---

## 📖 Documentación Detallada

- [📐 Arquitectura del Sistema](documentacion/arquitectura.md)
- [🔌 Documentación de Endpoints REST](documentacion/endpoints_api.md)
- [🚀 Guía de Instalación y Ejecución](documentacion/guia_instalacion.md)

---

## ⚡ Inicio Rápido

1. **Levantar backend y PostgreSQL:**
   ```bash
   docker compose up -d
   ```
2. **Ejecutar frontend Flutter:**
   ```bash
   cd front
   flutter run -d chrome
   ```
