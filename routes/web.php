<?php

use App\Http\Controllers\ProductController;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| contains the "web" middleware group. Now create something great!
|
*/
// Home
Route::get('/', 'ProductController@homepage');

// Pages

// Products
Route::get('/products', 'ProductController@index');

Route::get('/products/{id}', function($id) {
    return view('pages.product');
});
//

// User 
Route::get('signin', function () {
    return view('pages.signin');
});
Route::get('signup', function () {
    return view('pages.signup');
});
Route::get('checkout', function () {
    return view('pages.checkout');
});
Route::get('user', function () {
    return view('pages.user');
});

// API

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@login');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@showRegistrationForm')->name('register');
Route::post('register', 'Auth\RegisterController@register');
