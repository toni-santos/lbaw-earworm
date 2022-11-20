<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\Artist;

class ProductController extends Controller
{
    
    // will be used for product page
    public function show() {

    }

    public function list() {

    }

    // used for 
    public static function catalogue()
    {
        $products = Product::all()->take(30);

        foreach ($products as $product) {
            $product['artist_name'] = $product->artist->name;
        }

        return view('pages.catalogue', ['products' => $products]);
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

}
