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
// Home & Statics Pages
Route::get('/', 'ProductController@homepage')->name('home');
Route::view('/about-us', '/pages/aboutus')->name('about-us');

// Pages

// Products
Route::get('/product/{id}', 'ProductController@show')->name('product');
Route::get('/products', 'ProductController@catalogue')->name('catalogue');
Route::get('/product/buy/{id}', 'ProductController@buyProduct')->name('buyProduct');

// Artists
Route::get('/artist/{id}', 'ArtistController@show')->name('artist');

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
Route::post('/user/settings/change-password/{id}', 'UserController@updatePassword')->name('editpassword');
Route::get('/user/settings/recover-password/{id}', 'UserController@recoverPassword')->name('recoverpassword');

Route::get('/user/{id}', 'UserController@show')->name('profile');
Route::get('/user', 'UserController@ownprofile')->name('ownprofile');
Route::post('/cart/increase/{id}', 'ProductController@addToCart')->name('addToCart');
Route::post('/cart/decrease/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
Route::post('/cart/remove/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::post('/wishlist/add/{id}', 'ProductController@addToWishlist')->name('addToWishlist');
Route::post('/wishlist/remove/{id}', 'ProductController@removeFromWishlist')->name('removeFromWishlist');

// Admin
Route::get('/admin', 'AdminController@show')->name('adminIndex');
Route::get('/admin/signup', 'AdminController@showUserCreate')->name('adminCreatePage');
Route::get('/admin/user', 'AdminController@showUser')->name('adminUser');
Route::get('/admin/product', 'AdminController@showProduct')->name('adminProduct');
Route::get('/admin/artist', 'AdminController@showUser')->name('adminArtist');
Route::get('/admin/order', 'AdminController@showUser')->name('adminOrder');
Route::get('/admin/review', 'AdminController@showUser')->name('adminReview');
Route::post('/admin/user/create', 'AdminController@createUser')->name('adminCreateUser');
Route::post('/admin/user/delete', 'AdminController@deleteUser')->name('adminDeleteUser');
Route::post('/admin/user/edit/{id}', 'AdminController@updateUser')->name('adminUpdateUser');
Route::post('/admin/product/create', 'AdminController@createProduct')->name('adminCreateProduct');
Route::post('/admin/product/delete', 'AdminController@deleteProduct')->name('adminDeleteProduct');
Route::post('/admin/product/edit/{id}', 'AdminController@updateProduct')->name('adminUpdateProduct');

// Authentication
Route::get('login', 'Auth\LoginController@showLoginForm')->name('login');
Route::post('login', 'Auth\LoginController@authenticate')->name('authenticate');
Route::get('logout', 'Auth\LoginController@logout')->name('logout');
Route::get('register', 'Auth\RegisterController@show')->name('register');
Route::post('register', 'Auth\RegisterController@register')->name('registrate');

// Static
Route::get('about-us', function () {
    return view('pages.aboutus');
})->name('about-us');