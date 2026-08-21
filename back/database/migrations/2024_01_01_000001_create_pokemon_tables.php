<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Tabla Categorias (Tipos de Pokemon: fuego, agua, planta, etc.)
        Schema::create('categorias', function (Blueprint $table) {
            $table->id('categoria_id');
            $table->string('nombre_categoria')->unique();
            $table->timestamps();
        });

        // 2. Tabla Habilidades (overgrow, blaze, torrent, etc.)
        Schema::create('habilidades', function (Blueprint $table) {
            $table->id('habilidades_id');
            $table->string('nom_habilidades')->unique();
            $table->timestamps();
        });

        // 3. Tabla Pokemon
        Schema::create('pokemon', function (Blueprint $table) {
            $table->unsignedBigInteger('poke_id')->primary(); // ID proveniente de PokéAPI
            $table->string('nombre');
            $table->unsignedBigInteger('categoria_id')->nullable();
            $table->decimal('altura', 8, 2)->default(0);
            $table->decimal('peso', 8, 2)->default(0);
            $table->string('imagen_url', 500)->nullable();
            $table->timestamps();

            $table->foreign('categoria_id')
                  ->references('categoria_id')
                  ->on('categorias')
                  ->onDelete('set null');
        });

        // Tabla pivote de relacion muchos a muchos: Pokemon y Habilidades
        Schema::create('pokemon_habilidad', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('poke_id');
            $table->unsignedBigInteger('habilidades_id');
            $table->timestamps();

            $table->foreign('poke_id')
                  ->references('poke_id')
                  ->on('pokemon')
                  ->onDelete('cascade');

            $table->foreign('habilidades_id')
                  ->references('habilidades_id')
                  ->on('habilidades')
                  ->onDelete('cascade');
        });

        // 4. Tabla Poke_Favorito
        Schema::create('poke_favorito', function (Blueprint $table) {
            $table->id('favo_id');
            $table->unsignedBigInteger('poke_id');
            $table->unsignedBigInteger('categoria_id')->nullable();
            $table->unsignedBigInteger('habilidades_id')->nullable();
            $table->timestamps();

            $table->foreign('poke_id')
                  ->references('poke_id')
                  ->on('pokemon')
                  ->onDelete('cascade');

            $table->foreign('categoria_id')
                  ->references('categoria_id')
                  ->on('categorias')
                  ->onDelete('set null');

            $table->foreign('habilidades_id')
                  ->references('habilidades_id')
                  ->on('habilidades')
                  ->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('poke_favorito');
        Schema::dropIfExists('pokemon_habilidad');
        Schema::dropIfExists('pokemon');
        Schema::dropIfExists('habilidades');
        Schema::dropIfExists('categorias');
    }
};
