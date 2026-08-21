<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categoria extends Model
{
    use HasFactory;

    protected $table = 'categorias';
    protected $primaryKey = 'categoria_id';

    protected $fillable = [
        'nombre_categoria',
    ];

    public function pokemons()
    {
        return $this->hasMany(Pokemon::class, 'categoria_id', 'categoria_id');
    }
}
