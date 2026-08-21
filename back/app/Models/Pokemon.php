<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Pokemon extends Model
{
    use HasFactory;

    protected $table = 'pokemon';
    protected $primaryKey = 'poke_id';
    public $incrementing = false; // El ID viene directamente de PokéAPI

    protected $fillable = [
        'poke_id',
        'nombre',
        'categoria_id',
        'altura',
        'peso',
        'imagen_url',
    ];

    public function categoria()
    {
        return $this->belongsTo(Categoria::class, 'categoria_id', 'categoria_id');
    }

    public function habilidades()
    {
        return $this->belongsToMany(
            Habilidad::class,
            'pokemon_habilidad',
            'poke_id',
            'habilidades_id'
        );
    }

    public function favoritos()
    {
        return $this->hasMany(PokeFavorito::class, 'poke_id', 'poke_id');
    }
}
