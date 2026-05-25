<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Persona extends Model
{
    use HasFactory;

    // Estos son los campos que tu API podrá guardar en la base de datos
    protected $fillable = ['nombre', 'apellido', 'email'];
}
