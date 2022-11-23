<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\Listing;
use App\Models\Product;
use App\Models\Genre;
use App\Models\Artist;
use App\Models\Order;
use App\Models\OrderProduct;

class ProductController extends Controller
{

    // will be used for product page
    public function show($id) {

        $product = Product::findOrFail($id);
        $product['price'] /= 100;
        return view('pages.product', [
            'product' => $product,
            'products' => Product::all()->take(5),
            'genres' => $product->genres->toArray()
        ]);

    }

    public function list() {

    }

    public function buyProduct(int $id) {

        $this->addToCart($id);
        return to_route('product', ['id' => $id]);

    }

    public function addProduct() {
        $this->authorize('create', Product::class);
    }

    public static function homepage()
    {
        $trendingProducts = Product::all()->take(5);
        $fyProducts = Product::all()->take(5);

        foreach ($trendingProducts as $trendingProduct) {
            $trendingProduct['artist_name'] = $trendingProduct->artist->name;
            $trendingProduct['price'] = $trendingProduct->price/100;

        }
        foreach ($fyProducts as $fyProduct) {
            $fyProduct['artist_name'] = $fyProduct->artist->name;
            $fyProduct['price'] = $fyProduct->price/100;

        }

        return view('pages.index', ['trendingProducts' => $trendingProducts, 'fyProducts' => $fyProducts]);
    }

    // used to open catalogue & search catalogue 
    public static function catalogue()
    {
        $products = Product::search(request('search'))->paginate(20);
        $genres = Genre::all();

        foreach ($products as $product) {
            $product['artist_name'] = $product->artist->name;
            $product['price'] = $product->price/100;
        }

        return view('pages.catalogue', ['products' => $products, 'genres' => $genres]);

    }

    //test function
    public static function cart() {
        ProductController::addToCart(8);
    }

    public static function addToCart($id) {
        $product = Product::find($id);
        if (!$product) {
            abort(404);
        }

        $cart = session('cart');
        // if cart is empty then this the first product
        if (!$cart) {
            $cart = [
                $id => [
                    "name" => $product->name,
                    "quantity" => 1,
                    "price" => $product->price / 100,
                    ]
                ];
            session(['cart' => $cart]);
        } else if (isset($cart[$id])) {
            // if cart not empty then check if this product exist then increment quantity
            $cart[$id]['quantity']++;
            session(['cart' => $cart]);
        } else {
            // if item doesn't exist in cart then add to cart with quantity = 1
            $cart[$id] = [
                "name" => $product->name,
                "quantity" => 1,
                "price" => $product->price / 100,
                "photo" => $product->photo
            ];
            session(['cart' => $cart]);
        }
        
        return 200;

    }

    public function decreaseFromCart($id) {
        if ($id) {
            $cart = session()->get('cart');
            if(!isset($cart[$id])) {
                abort('404');
            }
            
            if ($cart[$id]['quantity'] == 0) 
                return redirect()->back()->with('success', 'Product quantity already at 0.');
            
            else if ($cart[$id]['quantity'] - 1 == 0) {
                unset($cart[$id]);
                session()->put('cart', $cart);
            }
            else {
                $cart[$id]['quantity']--;
                session()->put('cart', $cart);
            }
            return 200;
        }
    }

    public function removeFromCart($id) {
        if ($id) {
            $cart = session()->get('cart');
            if(isset($cart[$id])) {
                unset($cart[$id]);
                session()->put('cart', $cart);
            }
            else {
                abort('404');
            }
            return 200;
        }
    }

    public static function checkout() {
        return view('pages.checkout');
    }

    public function buy() {

        $cart = session()->get('cart');

        $order = Order::create([
            'user_id' => Auth::id(),
            'state' => 'Delivered'
        ]);

        foreach ($cart as $id => $product) {

            DB::table('order_product')->insert([
                'order_id' => $order->id,
                'product_id' => $id,
                'quantity' => $product['quantity']
            ]);

            $this->removeFromCart($id);

        }
        return to_route('home');
    }
}
