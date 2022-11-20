<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Listing;
use App\Models\Product;
use App\Models\Artist;

class ProductController extends Controller
{
    
    // will be used for product page
    public function show() {

    }

    public function list() {

    }

    public static function homepage()
    {
        $trendingProducts = Product::all()->take(5);
        $fyProducts = Product::all()->take(5);

        foreach ($trendingProducts as $trendingProduct) {
            $trendingProduct['artist_name'] = $trendingProduct->artist->name;
        }
        foreach ($fyProducts as $fyProduct) {
            $fyProduct['artist_name'] = $fyProduct->artist->name;
        }

        return view('pages.index', ['trendingProducts' => $trendingProducts, 'fyProducts' => $fyProducts]);
    }

    // used for open catalogue & search catalogue 
    public static function catalogue()
    {
        
        $products = Product::search(request('search'))->paginate(20);

        foreach ($products as $product) {
            $product['artist_name'] = $product->artist->name;
        }

        return view('pages.catalogue', ['products' => $products]);
    }

    //test function
    public static function cart() {
        ProductController::addToCart(2);
        ProductController::homepage();
    }

    public static function addToCart($id) {

        $product = Product::find($id);
        if (!$product) {
            abort(404);
        }

        $cart = session()->get('cart');
        // if cart is empty then this the first product
        if (!$cart) {
            $cart = [
                    $id => [
                        "name" => $product->name,
                        "quantity" => 1,
                        "price" => $product->price / 100,
                    ]
            ];
            session()->put('cart', $cart);
            return redirect()->back()->with('success', 'Product added to cart successfully!');
        }
        // if cart not empty then check if this product exist then increment quantity
        if (isset($cart[$id])) {
            $cart[$id]['quantity']++;
            session()->put('cart', $cart);
            return redirect()->back()->with('success', 'Product added to cart successfully!');
        }
        // if item doesn't exist in cart then add to cart with quantity = 1
        $cart[$id] = [
            "name" => $product->name,
            "quantity" => 1,
            "price" => $product->price / 100,
            "photo" => $product->photo
        ];
        session()->put('cart', $cart);
        return redirect()->back()->with('success', 'Product added to cart successfully!');
    }

    public function decreaseFromCart($id) {
        if ($id) {
            $cart = session()->get('cart');
            if ($cart[$id]['quantity'] - 1 == 0) {
                unset($cart[$id]);
                session()->put('cart', $cart);
            }
            else {
                $cart[$id]['quantity']--;
                session()->put('cart', $cart);
            }
            return redirect()->back()->with('success', 'Product quantity decreased successfully!');
        }
    }

    public function removeFromCart($id) {
        if ($id) {
            $cart = session()->get('cart');
            if(isset($cart[$id])) {
                unset($cart[$id]);
                session()->put('cart', $cart);
            }
            return redirect()->back()->with('success', 'Product removed from cart successfully!');
        }
    }

    public static function checkout() {

        return view('pages.checkout');
    }
}
