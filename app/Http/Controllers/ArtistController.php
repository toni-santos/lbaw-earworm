<?php

namespace App\Http\Controllers;

use App\Models\Artist;
use App\Models\Product;
use Illuminate\Http\Request;
use App\Models\User;
use App\Http\Controllers\UserController;

use Illuminate\Support\Facades\Auth;


class ArtistController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Display the specified resource.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function show(int $id)
    {
        $user = Auth::user();

        $artist = Artist::findOr($id, fn() => abort(404, 'Artist not found.'));
        $products = Product::all()->where('artist_id', $id);

        foreach ($products as $product) {
            $product['artist_name'] = $product->artist->name;
            $product['price'] = $product->price/100;
            $product['discounted_price'] = ProductController::getDiscountedPrice($product->price, $product->discount);
        }
        
        $wishlist = UserController::getWishlist();
        $pfp = UploadController::getArtistProfilePic($id);

        $favArtist = $user->favouriteArtists->contains('id', $id);

        return view('pages.artist', [
            'artist' => $artist,
            'pfp' => $pfp,
            'products' => $products,
            'wishlist' => $wishlist,
            'favArtist' => $favArtist
        ]);
    }
}
