<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\PersonaController;
use App\Http\Controllers\PokemonController; // Importante añadir esta línea

// Rutas públicas: Cualquier persona puede registrarse o loguearse
Route::post('register', [AuthController::class, 'register']);
Route::post('login', [AuthController::class, 'login']);

// Rutas protegidas: Solo accesibles si envías el Token de Sanctum
Route::middleware('auth:sanctum')->group(function () {

    // Obtener datos del usuario autenticado
    Route::get('/user', function (Request $request) {
        return $request->user();
    });

    // Rutas para el CRUD de Personas (index, store, show, update, destroy)
    Route::apiResource('personas', PersonaController::class);

    Route::delete('/personas/{persona}', [PersonaController::class, 'destroy']);

    // Cerrar sesión y eliminar el token actual
    Route::post('logout', [AuthController::class, 'logout']);
});
Route::get('/pokemons', [PokemonController::class, 'index']);
