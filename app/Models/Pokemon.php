<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pokemon extends Model
{
    protected $table = 'pokemons';// Permitimos que el Seeder guarde estos datos de forma automática
    protected $fillable = ['pokedex_number', 'nombre', 'tipo_1', 'tipo_2', 'imagen_url'];
}
