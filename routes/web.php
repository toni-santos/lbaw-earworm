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

// Orders
Route::get('/order', 'ProductController@showOrder')->name('order');

//test func
Route::get('/get-admin', 'UserController@getAdmin')->name('getadmin');

//Route::get('/add-to-cart/{id}', 'ProductController@addToCart')->name('addToCart');
//Route::get('/decrease-from-cart/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
//Route::get('/remove-from-cart/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::get('/cart', 'ProductController@cart')->name('cart');
Route::get('/checkout', 'ProductController@checkout')->name('checkout');
Route::post('/checkout', 'OrderController@buy')->name('buy');
Route::get('/wishlist', 'ProductController@wishlist')->name('wishlist');

// User 
Route::get('/user/settings/{id}', 'UserController@editProfile')->name('editprofile');
Route::post('/user/settings/{id}', 'UserController@update')->name('editprofilepost');
Route::post('/user/settings/change-password/{id}', 'UserController@updatePassword')->name('editpassword');
Route::get('/user/settings/recover-password/{id}', 'UserController@recoverPassword')->name('recoverpassword');
Route::get('/user/settings/delete/{id}', 'UserController@deleteAccount')->name('deleteAccount');
Route::post('/user/settings/last_fm/login', 'UserController@loginLastFm')->name('loginLastFm');
Route::post('/user/settings/last_fm/logout', 'UserController@logoutLastFm')->name('logoutLastFm');
Route::get('/user/{id}', 'UserController@show')->name('profile');
Route::get('/user', 'UserController@ownprofile')->name('ownprofile');
Route::post('/cart/increase/{id}', 'ProductController@addToCart')->name('addToCart');
Route::post('/cart/decrease/{id}', 'ProductController@decreaseFromCart')->name('decreaseFromCart');
Route::post('/cart/remove/{id}', 'ProductController@removeFromCart')->name('removeFromCart');
Route::post('/wishlist/add/{id}', 'ProductController@addToWishlist')->name('addToWishlist');
Route::post('/wishlist/remove/{id}', 'ProductController@removeFromWishlist')->name('removeFromWishlist');
Route::post('/product/review/{id}', 'ProductController@addReview')->name('addReview');
Route::post('/product/edit-review/{user_id}-{product_id}', 'ProductController@editReview')->name('editReview');
Route::post('/product/delete-review/{user_id}-{product_id}', 'ProductController@deleteReview')->name('deleteReview');

// Admin
Route::get('/admin', 'AdminController@show')->name('adminIndex');
Route::get('/admin/signup', 'AdminController@showUserCreate')->name('adminCreatePage');
Route::get('/admin/user', 'AdminController@showUser')->name('adminUser');
Route::get('/admin/product', 'AdminController@showProduct')->name('adminProduct');
Route::get('/admin/artist', 'AdminController@showArtist')->name('adminArtist');
Route::get('/admin/order', 'AdminController@showOrder')->name('adminOrder');
Route::get('/admin/review', 'AdminController@showUser')->name('adminMod');
Route::post('/admin/user/create', 'AdminController@createUser')->name('adminCreateUser');
Route::post('/admin/user/delete', 'AdminController@deleteUser')->name('adminDeleteUser');
Route::post('/admin/user/edit/{id}', 'AdminController@updateUser')->name('adminUpdateUser');
Route::get('/admin/product/create', 'AdminController@showProductCreate')->name('adminCreateProduct');
Route::post('/admin/product/create', 'AdminController@createProduct')->name('adminCreateProductPost');
Route::post('/admin/product/delete', 'AdminController@deleteProduct')->name('adminDeleteProduct');
Route::post('/admin/product/edit/{id}', 'AdminController@updateProduct')->name('adminUpdateProduct');
Route::post('/admin/artist/create', 'AdminController@createArtist')->name('adminCreateArtist');
Route::post('/admin/artist/edit/{id}', 'AdminController@updateArtist')->name('adminUpdateArtist');
Route::post('/admin/order/create', 'AdminController@createArtist')->name('adminCreateOrder');
Route::post('/admin/order/delete', 'AdminController@deleteArtist')->name('adminDeleteOrder');
Route::post('/admin/order/edit/{id}', 'AdminController@updateArtist')->name('adminUpdateOrder');

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

Route::get('help', function () {
    return view('pages.help');
})->name('help');