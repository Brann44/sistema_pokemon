<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class PokeFavorito extends Model
{
    use HasFactory;

    protected $table = 'poke_favorito';
    protected $primaryKey = 'favo_id';

    protected $fillable = [
        'poke_id',
        'categoria_id',
        'habilidades_id',
    ];

    public function pokemon()
    {
        return $this->belongsTo(Pokemon::class, 'poke_id', 'poke_id');
    }

    public function categoria()
    {
        return $this->belongsTo(Categoria::class, 'categoria_id', 'categoria_id');
    }

    public function habilidad()
    {
        return $this->belongsTo(Habilidad::class, 'habilidades_id', 'habilidades_id');
    }
}
