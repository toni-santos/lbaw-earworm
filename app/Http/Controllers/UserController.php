<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Product;
use App\Models\Review;
use Illuminate\Http\Request;

use Illuminate\Support\Facades\Auth;


class UserController extends Controller
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
    public function show($id)
    {
        $user = User::findOrFail($id);
        if ($user->is_blocked) {
            abort(404);
        }
        
        $favArtists = $user->favouriteArtists->toArray();
        $orders = $user->orders;

        $boughtProducts = [];

        foreach ($orders as $order) {
            foreach ($order->products as $product) {
                array_push($boughtProducts, $product);
            }

        }

        $recommendedProducts = Product::inRandomOrder()->limit(10)->get();
        foreach ($recommendedProducts as $suggestProduct) {
            $suggestProduct['artist_name'] = $suggestProduct->artist->name;
            $suggestProduct['price'] = $suggestProduct->price/100;
        }

        $wishlist = getWishlist();

        $reviews = Review::all()->where('reviewer_id', $id);
        foreach ($reviews as $review) {
            $review['product'] = Product::all()->find($review['product_id']);
            $review['reviewer'] = User::all()->find($review['reviewer_id']);
        }

        return view('pages.user', [
            'user' => $user,
            'favArtists' => $favArtists,
            'purchaseHistory' => $boughtProducts,
            'recommendedProducts' => $recommendedProducts,
            'wishlist' => $wishlist,
            'reviews' => $reviews
        ]);
    }

    public function ownprofile()
    {
        if (Auth::id()) {
            return to_route('profile', ['id' => Auth::id()]);
        }
        else {
            return to_route('login');
        }
    }


    /**
     * Show the form for creating a new resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        //
    }

    public function editProfile(int $id) {
        $user = User::findOrFail($id);
        if (!(Auth::user()->is_admin || Auth::id() == $id)) abort(403);
        return view('pages.settings', ['user' => $user]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, int $id)
    {
        $user = User::findOrFail($id);
        if ($user->is_blocked) {
            abort(404);
        }
        
        $data = $request->toArray();

        if ($user->is_admin) {
            $user->is_blocked = array_key_exists('block', $data);
        }

        $user->username = $data['username'] ?? $user->username;
        $user->email = $data['email'] ?? $user->email;

        $user->save();

        return to_route('profile', ['id' => $id]);
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function destroy(User $user)
    {
        //
    }
}

function getWishlist() {
    if (Auth::check()) {
        $user = User::findOrFail(Auth::id());
        $list = $user->wishlist->toArray();
        $wishlist = [];
        foreach ($list as $product) {
            $wishlist[] = $product['id'];
        }
        
        return $wishlist;
    }
    
    return [];
}
