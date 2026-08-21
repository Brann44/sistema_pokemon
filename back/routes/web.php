<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'message' => 'API de Sistema Pokémon activa y funcionando 🚀',
        'status' => 'OK'
    ]);
});
