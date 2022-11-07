<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\MaiController;
/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::post('RegistrarEmpleado', [AuthController::class, 'RegistrarEmpleado']);
Route::post('ActualizarEmpleado', [
    AuthController::class,
    'ActualizarEmpleado',
]);

Route::get('verEmpleados', [AuthController::class, 'verEmpleados']);

Route::post('DeleteEmpleado', [AuthController::class, 'DeleteEmpleado']);

Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
    return $request->user();
});
