<?php

namespace App\Http\Controllers;

use App\Models\Persona;
use Illuminate\Http\Request;

class PersonaController extends Controller
{
    /**
     * Muestra una lista de todas las personas.
     */
    public function index()
    {
        return Persona::all();
    }

    /**
     * Guarda una nueva persona en la base de datos.
     */
    public function store(Request $request)
    {
        $request->validate([
            'nombre' => 'required|string|max:255',
            'apellido' => 'required|string|max:255',
            'email' => 'required|email|unique:personas,email',
        ]);

        return Persona::create($request->all());
    }

    /**
     * Muestra los datos de una persona específica.
     */
    public function show(Persona $persona)
    {
        return $persona;
    }

    /**
     * Actualiza los datos de una persona existente.
     */
    public function update(Request $request, Persona $persona)
    {
        $persona->update($request->all());
        return $persona;
    }

    /**
     * Elimina una persona de la base de datos.
     */
    public function destroy(Persona $persona)
    {
        $persona->delete();
        return response()->json(null, 204);
    }
}
