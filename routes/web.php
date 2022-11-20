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
Route::get('/', 'ProductController@homepage')->name('home');

// Pages

// Products
Route::get('/products', 'ProductController@catalogue')->name('catalogue');
Route::get('/products/{id}', function($id) {
    return view('pages.product');
});

// Cart

//test func
Route::get('/cart', 'ProductController@cart')->name('cart');

Route::get('/add-to-cart/{id}', 'ProductController@addToCart')->name('addToCart');
Route::get('/decrease-from-cart/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
Route::get('/remove-from-cart/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::get('/checkout', 'ProductController@checkout')->name('checkout');

Route::get('user', function () {
    return view('pages.user');
});

// API

// User 
Route::get('signin', function () {
    return view('pages.signin');
}) ->name('signin');
Route::get('signup', function () {
    return view('pages.signup');
})->name('signup');
Route::get('user', function () {
    return view('pages.user');
});

// API

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@authenticate')->name('login');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@show')->name('register');
Route::post('register', 'Auth\RegisterController@register')->name('register');
