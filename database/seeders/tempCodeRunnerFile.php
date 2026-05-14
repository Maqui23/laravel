<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Http;
use App\Models\Pokemon;

class PokemonSeeder extends Seeder
{
    public function run(): void
    {
        // Cambia el 20 por 1025 cuando estés listo para descargar todos
        for ($i = 1; $i <= 1025; $i++) {

            // Hacemos la petición a la PokéAPI
            $response = Http::get("https://pokeapi.co/api/v2/pokemon/{$i}");

            if ($response->successful()) {
                $data = $response->json();

                // Guardamos en tu tabla de MySQL
                Pokemon::create([
                    'pokedex_number' => $data['id'],
                    'nombre' => $data['name'],
                    // El tipo 1 siempre existe
                    'tipo_1' => $data['types'][0]['type']['name'],
                    // El tipo 2 es opcional (no todos tienen dos tipos)
                    'tipo_2' => isset($data['types'][1]) ? $data['types'][1]['type']['name'] : null,
                    // Sacamos la imagen frontal estándar
                    'imagen_url' => $data['sprites']['front_default'],
                ]);
            }
        }
    }
}