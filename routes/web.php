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
Route::get('/product/{id}', 'ProductController@show')->name('product');

//test func
Route::get('/cart', 'ProductController@cart')->name('cart');

//Route::get('/add-to-cart/{id}', 'ProductController@addToCart')->name('addToCart');
//Route::get('/decrease-from-cart/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
//Route::get('/remove-from-cart/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::get('/checkout', 'ProductController@checkout')->name('checkout');


// User 
Route::get('/user/{id}', 'UserController@show')->name('profile');
Route::get('/user', 'UserController@ownprofile')->name('ownprofile');
Route::get('/user/{id}/settings', 'UserController@editProfile')->name('editprofile');
Route::post('/user/{id}/settings', 'UserController@update')->name('editprofile');
Route::post('/cart/increase/{id}', 'ProductController@addToCart')->name('addToCart');
Route::post('/cart/decrease/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
Route::post('/cart/remove/{id}', 'ProductController@removeFromCart')->name('removeFromCart');


// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@authenticate')->name('login');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@show')->name('register');
Route::post('register', 'Auth\RegisterController@register')->name('register');
