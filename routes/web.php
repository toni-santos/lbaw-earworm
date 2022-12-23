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
Route::get('/product/{id}', 'ProductController@show')->name('product');
Route::get('/products', 'ProductController@catalogue')->name('catalogue');
Route::get('/product/buy/{id}', 'ProductController@buyProduct')->name('buyProduct');

//test func
Route::get('/cart', 'ProductController@cart')->name('cart');

//Route::get('/add-to-cart/{id}', 'ProductController@addToCart')->name('addToCart');
//Route::get('/decrease-from-cart/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
//Route::get('/remove-from-cart/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::get('/checkout', 'ProductController@checkout')->name('checkout');
Route::post('/checkout', 'ProductController@buy')->name('buy');
Route::get('/wishlist', 'ProductController@wishlist')->name('wishlist');

// User 
Route::get('/user/settings/{id}', 'UserController@editProfile')->name('editprofile');
Route::post('/user/settings/{id}', 'UserController@update')->name('editprofilepost');
Route::get('/user/{id}', 'UserController@show')->name('profile');
Route::get('/user', 'UserController@ownprofile')->name('ownprofile');
Route::post('/cart/increase/{id}', 'ProductController@addToCart')->name('addToCart');
Route::post('/cart/decrease/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
Route::post('/cart/remove/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::post('/wishlist/add/{id}', 'ProductController@addToWishlist')->name('addToWishlist');

// Admin
Route::get('/admin/create', 'AdminController@showUserCreate')->name('adminCreatePage');
Route::post('/admin/create', 'AdminController@create')->name('adminCreateAction');
Route::post('/admin/delete', 'AdminController@deleteUser')->name('deleteUser');
Route::post('/admin/{id}', 'AdminController@update')->name('adminedit');
Route::get('/admin', 'AdminController@show')->name('adminpage');

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@authenticate')->name('authenticate');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@show')->name('register');
Route::post('register', 'Auth\RegisterController@register')->name('registrate');
