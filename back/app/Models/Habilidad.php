<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Habilidad extends Model
{
    use HasFactory;

    protected $table = 'habilidades';
    protected $primaryKey = 'habilidades_id';

    protected $fillable = [
        'nom_habilidades',
    ];

    public function pokemons()
    {
        return $this->belongsToMany(
            Pokemon::class,
            'pokemon_habilidad',
            'habilidades_id',
            'poke_id'
        );
    }
}
