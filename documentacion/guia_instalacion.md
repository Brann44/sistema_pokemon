# 🚀 Guía de Instalación y Ejecución

Esta guía explica paso a paso cómo iniciar y probar el **Sistema Pokémon** en tu máquina local.

---

## 📋 Requisitos Previos

- **Git** instalado.
- **Docker Desktop** instalado y en ejecución.
- **Flutter SDK** instalado (para el frontend).

---

## 🐳 Paso 1: Levantar el Backend y PostgreSQL con Docker

Desde la carpeta raíz del proyecto (`sistema_pokemon/`):

1. **Asegúrate de que Docker Desktop esté abierto y corriendo.**
2. **Construye y levanta los contenedores:**
   ```bash
   docker compose up -d
   ```
3. **Ejecuta las migraciones de base de datos:**
   ```bash
   docker compose exec laravel_app php artisan migrate
   ```
4. El backend estará disponible y escuchando en:
   👉 **`http://localhost:8000/api`**

---

## 💙 Paso 2: Ejecutar el Frontend Flutter

1. Abre una terminal y dirígete a la carpeta `front/`:
   ```bash
   cd front
   ```
2. Instala las dependencias:
   ```bash
   flutter pub get
   ```
3. Ejecuta la aplicación en el dispositivo o plataforma de tu elección:

   * **En Navegador Web (Chrome):**
     ```bash
     flutter run -d chrome
     ```
   * **En Windows Desktop:**
     ```bash
     flutter run -d windows
     ```
   * **En Emulador Android:**
     ```bash
     flutter run -d android
     ```

---

## 🌿 Paso 3: Gestión de Ramas en Git

El repositorio está configurado con las dos ramas solicitadas:

- **`main`**: Código estable y funcional de producción.
- **`staging`**: Rama de desarrollo e integración continua.

### Comandos útiles de Git:
```bash
# Ver estado actual
git status

# Cambiar a la rama de desarrollo
git checkout staging

# Subir cambios a staging
git push origin staging

# Fusionar staging a main
git checkout main
git merge staging
git push origin main
```
