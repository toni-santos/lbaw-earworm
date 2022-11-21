<?php

use Illuminate\Http\Request;

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

Route::middleware('api')->group(function () {

    Route::middleware('auth')->get('/user', 'Auth\LoginController@getUser');

    Route::post('/cart/increase/{id}', 'ProductController@addToCart')->name('addToCart');
    Route::post('/cart/decrease/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
    Route::post('/cart/remove/{id}', 'ProductController@removeFromCart')->name('removeFromCart');

});

