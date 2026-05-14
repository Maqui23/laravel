<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Pokemon; // <-- ¡Muy importante esta línea para conectar el Modelo!

class PokemonController extends Controller
{
    public function index()
    {
        // Buscamos todos los Pokémon en la base de datos
        $pokemons = Pokemon::all();

        // Los devolvemos para que la aplicación móvil los entienda
        return response()->json($pokemons);
    }
}
