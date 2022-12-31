<?php

namespace App\Http\Controllers;

use ArrayObject;
use App\Http\Controllers\UserController;
use App\Models\Product;
use App\Models\Genre;
use App\Models\User;
use App\Models\Review;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;

class ProductController extends Controller
{

    // will be used for product page
    public function show(int $id) {

        $product = Product::findOrFail($id);
        $product['price'] = ProductController::formatPrice($product->price/100);
        $product['discounted_price'] = ProductController::getDiscountedPrice($product->price, $product->discount);

        // if ($product['discount'] != 0) $product['price'] = ($product['discount']/100) * $product['price'];
        $products = Product::inRandomOrder()->limit(10)->get();
        foreach ($products as $suggestProduct) {
            $suggestProduct['artist_name'] = $suggestProduct->artist->name;
            $suggestProduct['price'] = ProductController::formatPrice($suggestProduct->price/100);
            $suggestProduct['discounted_price'] = ProductController::getDiscountedPrice($product->price, $product->discount);
   
        }

        $wishlist = UserController::getWishlist();

        $logged = false;
        if (Auth::check()) {
            $user_id = Auth::id();
            $logged = true;
        }
        
        $reviews = Review::all()->where('product_id', $id);
        $reviewsTrimmed = array();
        foreach ($reviews as $review) {
            $review['product'] = Product::all()->find($review['product_id']);
            $review['reviewer'] = User::all()->find($review['reviewer_id']);
            if ($logged) {
                if ($user_id == $review['reviewer_id']) 
                    $product['previous_review'] = $review;
                else 
                    array_push($reviewsTrimmed, $review);
            }
            else {
                array_push($reviewsTrimmed, $review);
            }
        }

        $pfp = UploadController::getProductProfilePic($id);

        return view('pages.product', [
            'product' => $product,
            'pfp' => $pfp,
            'products' => $products,
            'genres' => $product->genres->toArray(),
            'wishlist' => $wishlist,
            'reviews' => $reviewsTrimmed
        ]);

    }

    public function list() {

    }

    public function buyProduct(int $id) {

        $this->addToCart($id);
        return back()->with(['message' => 'Product was added to your cart!']);

    }

    public function addProduct() {
        $this->authorize('create', Product::class);
    }

    public static function formatPrice($price) {
        return number_format((float)$price, 2, '.', '');
    }

    public static function getDiscountedPrice($price, $discount) {
        if ($discount == 0) {
            return $price;
        } else {
            $new_price = round($price * (100 - $discount) / 100);
            return ProductController::formatPrice($new_price);
        }
    }

    public static function homepage()
    {
        $trendingProducts = Product::inRandomOrder()->limit(10)->get();
        $recommendedProducts = session('for_you') ?? [];
        
        $recommendation_info = array();
        foreach ($recommendedProducts as $id => $recommendation) {
            $recommendation_info[$id] = clone $recommendation;
        }

        foreach ($trendingProducts as $trendingProduct) {
            
            $trendingProduct['artist_name'] = $trendingProduct->artist->name;
            $trendingProduct['price'] = ProductController::formatPrice($trendingProduct->price / 100);
            $trendingProduct['discounted_price'] = ProductController::getDiscountedPrice($trendingProduct->price, $trendingProduct->discount);

        }

        foreach ($recommendation_info as $fyProduct) {

            $fyProduct['artist_name'] = $fyProduct->artist->name;
            $fyProduct['price'] = ProductController::formatPrice($fyProduct->price / 100);
            $fyProduct['discounted_price'] = ProductController::getDiscountedPrice($fyProduct->price, $fyProduct->discount);

        }

        $wishlist = UserController::getWishlist();
        return view('pages.index', ['trendingProducts' => $trendingProducts, 'fyProducts' => $recommendation_info, 'wishlist' => $wishlist]);
        
    }

    public static function yearList($products) {
        $years = [];
        $products = $products->orderBy('year', 'asc')->get();
        foreach ($products as $product) {
            array_push($years, $product->year - ($product->year % 10));
        }
        $years = array_unique($years);
        return $years;
    }

    public static function formatList() {
        return ['CD', 'Vinyl', 'Cassette', 'DVD', 'Box Set'];
    }

    // used to open catalogue & search catalogue 
    public static function catalogue(Request $request) {
        $allProducts = DB::table('product')->select('*');

        $genres = Genre::all();
        $activeGenres = [];

        $years = ProductController::yearList($allProducts);
        $activeYears = [];

        $formats = ProductController::formatList();
        $activeFormats = [];

        $products = Product::search(request('search'));
        $input = $request->all();

        foreach ($input as $parameter) {
            if (!isset($parameter))
                continue;
            $key = array_search($parameter, $input);
            $productIds = [];
            switch ($key) {
                case "min-price":
                    $products = $products->where('price', '>=', floatval($parameter)*100);
                    break;

                case "max-price":
                    $products = $products->where('price', '<=', floatval($parameter)*100);
                    break;

                case "min-rating":
                    $products = $products->where('rating', '>=', floatval($parameter));
                    break;

                case "max-rating":
                    $products = $products->where('rating', '<=', floatval($parameter));
                    break;

                case "genre":
                    $activeGenres = $parameter;
                    foreach ($products->get() as $product) {

                        $productGenres = $product->genres->toArray();
                        $genreNames = [];
                        
                        foreach ($productGenres as $productGenre) {

                            array_push($genreNames, $productGenre['name']);
                        }
                        
                        if(!array_diff($activeGenres, $genreNames)) {
                            array_push($productIds, $product['id']);
                        }
                    }
                    $products = $products->whereIn('id', $productIds);
                    break;

                case "year":
                    $activeYears = array_map('intval', $parameter);
                    foreach ($products->get() as $product) {

                        $productYear = $product->year;
                        foreach ($activeYears as $year) {

                            if (($productYear - $year >= 0) && ($productYear - $year) <= 9) {
                                array_push($productIds, $product['id']);
                            }
                        }
                    }
                    $products = $products->whereIn('id', $productIds);
                    break;

                case "format":
                    $activeFormats = $parameter;
                    foreach ($products->get() as $product) {

                        $productFormat = $product->format;
                        if (in_array($productFormat, $activeFormats)) {
                            array_push($productIds, $product['id']);
                        }
                    }
                    $products = $products->whereIn('id', $productIds);
                    break;

                case "ord":
                    if ($parameter == 'relevance')
                        break;
                    list($attribute, $order) = explode('-', $parameter);
                    $products = $products->reorder($attribute, $order);
                    break;

                default:
                    break;
            }
        }

        $products = $products->paginate(21)->withQueryString();

        foreach ($products as $product) {
            $product['artist_name'] = $product->artist->name;
            $product['price'] = ProductController::formatPrice($product->price / 100);
            $product['discounted_price'] = ProductController::getDiscountedPrice($product->price, $product->discount);
        }

        $wishlist = UserController::getWishlist();

        return view('pages.catalogue', 
        [
            'products' => $products, 
            'genres' => $genres, 
            'activeGenres' => $activeGenres,
            'years' => $years,
            'activeYears' => $activeYears,
            'formats' => $formats,
            'activeFormats' => $activeFormats,
            'wishlist' => $wishlist
        ]);

    }

    public static function addToCart(int $id) {
        $product = Product::find($id);
        if (!$product) {
            abort(404);
        }

        $cart = session('cart');
        $product['price'] = ProductController::formatPrice($product->price / 100);
        $product['discounted_price'] = ProductController::getDiscountedPrice($product->price, $product->discount);
        // if cart is empty then this the first product
        if (!$cart) {
            $cart = [
                $id => [
                        "name" => $product->name,
                        "quantity" => 1,
                        "price" => $product->price,
                        "photo" => $product->photo,
                        'discounted_price' => $product->discounted_price
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
                "price" => $product->price,
                "photo" => $product->photo,
                'discounted_price' => $product->discounted_price
            ];
            session(['cart' => $cart]);
        }
        
        return 200;

    }

    public function decreaseFromCart(int $id) {
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

    public static function removeFromCart(int $id) {
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

    public static function cart() {
        return view('pages.cart');
    }

    public static function checkout() {

        $countries = Cache::remember('countries', 600, function () {
            $countries = json_decode(file_get_contents("https://restcountries.com/v3.1/all"), true);
            usort($countries, fn($a, $b) => $a['name']['common'] <=> $b['name']['common']);
            return $countries;
        });

        return view('pages.checkout', ['countries' => $countries]);
    }

    public static function wishlist(Request $request) {

        $user = User::findOrFail(Auth::id());
        $wishlist = $user->wishlist->toArray();

        return view('pages.wishlist', ['wishlist' => $wishlist]);

    }

    public function addToWishlist(int $id) {
        
        if (!Auth::check()) abort(403);
        $user_id = Auth::id();

        DB::table('wishlist_product')->insert([
            'wishlist_id' => $user_id,
            'product_id' => $id
        ]);

        return 200;
    }

    public function removeFromWishlist(int $id) {
        
        if (!Auth::check()) abort(403);
        $user_id = Auth::id();

        $deleted = DB::table('wishlist_product')
                        ->where('wishlist_id', $user_id)
                        ->where('product_id', $id)->delete();

        return 200;
    }

    public function addReview(Request $request, int $id) {
        if (!Auth::check()) abort(403);
        $user_id = Auth::id();
        $data = $request->toArray();

        DB::table('review')->insert([
            'reviewer_id' => $user_id,
            'product_id' => $id,
            'score' => $data['rating-star'],
            'message' => $data['message']
        ]);
        
        return to_route('product', ['id' => $id]);
    }

    public function editReview(Request $request, int $user_id, int $product_id) {

        if (!Auth::check()) abort(403);
        if ((Auth::id() != $user_id) && !Auth::user()->is_admin) abort(401);

        $data = $request->toArray();

        $review = Review::all()->where('reviewer_id', '=', $user_id)
                               ->where('product_id', '=', $product_id)->first();
        if (!$review) abort(404);

        $review->message = $data['message'] ?? $review->message;
        $review->score = $data['rating-star'] ?? $review->score;
        $date = date("Y-m-d");
        $review->created_at = $date ?? $review->created_at;

        DB::table('review')->where('reviewer_id', '=', $user_id)
        ->where('product_id', '=', $product_id)
        ->update(['message' => $review->message, 'score' => $review->score, 'created_at' => $review->created_at]);
        
        return redirect()->back()->with(['message' => 'Review edited!']);
    }

    public function deleteReview(Request $request, int $user_id, int $product_id) {
        if (!Auth::check()) abort(403);
        if ((Auth::id() != $user_id) && !Auth::user()->is_admin) abort(401);

        $data = $request->toArray();

        Review::where([
            'reviewer_id' => $user_id,
            'product_id' => $product_id,
        ])->delete();
        
        return redirect()->back()->with(['message' => 'Review deleted.']);
    }

    public function notification() {
        return view('pages.notification');
    }
 }