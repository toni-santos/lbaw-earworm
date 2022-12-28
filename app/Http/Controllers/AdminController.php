<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Models\Product;
use App\Models\Order;
use App\Models\Artist;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    /**
     * Display the specified resource.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function show(Request $request)
    {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);

        $products = Product::all()->sortBy('stock', false)->take(5);
        // $orders = Order::all()->orderBy('', 'asc')->limit(5);
        return view('pages.admin.index', ['products' => $products]);
    }


    public function showUser(Request $request)
    {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);

        $search = (array_key_exists('user', $request->toArray())) ? $request->toArray()['user'] : '';
        
        $users = User::search($search)->where('is_admin', 0)->where('is_deleted', 0);
        $users = $users->paginate(20)->withQueryString();
        return view('pages.admin.user', ['users' => $users]);
    }


    public function showProduct(Request $request) {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);
        
        $search = (array_key_exists('product', $request->toArray())) ? $request->toArray()['product'] : '';
        if ($search) {
            $products = Product::adminSearch($search);
            $products = $products->paginate(20)->withQueryString();
        } else {
            $products = Product::paginate(20)->withQueryString();
        }
        return view('pages.admin.product', ['products' => $products]);
    }

    public function showArtist(Request $request) {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);
        
        $search = (array_key_exists('artist', $request->toArray())) ? $request->toArray()['artist'] : '';

        $artists = Artist::search($search);
        $artists = $artists->paginate(20)->withQueryString();
        return view('pages.admin.artist', ['artists' => $artists]);
    }

    public function showOrder(Request $request) {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);
        
        $search = (array_key_exists('order', $request->toArray())) ? $request->toArray()['order'] : '';
        if ($search) {
            $orders = Order::where('id', 'LIKE', $search)
                            ->orWhere('user_id', 'LIKE', $search);
            $orders = $orders->paginate(20)->withQueryString();
        } else {
            $orders = Order::paginate(20)->withQueryString();
        }
        
        foreach ($orders as $order) {
            $order['products'] = $order->products;
            foreach($order['products'] as $product) {
                $product['artist_name'] = $product->artist->name;
            }
        }

        return view('pages.admin.orders', ['orders' => $orders]);
    }

    public function showUserCreate() 
    {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);

        return view('auth.admin-create');
    }

    public function showProductCreate() 
    {
        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);

        $artists = Artist::all();

        return view('auth.admin-product-create', ['artists' => $artists]);
    }

   /**
     * Create a new user after a valid registration.
     *
     * @param  array  $data
     * @return \App\Models\User
     */
    public function createUser(Request $request) {
        $data = $request->toArray();

        $user = User::where('email', $data['email'])->first();
        
        if (!is_null($user))
            return back()->withErrors('User already exists.');

        User::create([
            'email' => $data['email'],
            'username' => $data['username'],
            'password' => bcrypt($data['pwd']),
            'is_admin' => array_key_exists('admin', $data)
        ]);

        return to_route('adminUser');
    }

    /**
     * Show the form for editing the specified resource.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function editUser(User $user)
    {
        return view('pages.settings', ['id' => $user->id]);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\Response
     */
    public function updateUser(Request $request, int $id)
    {
        $user = User::findOrFail($id);
        $data = $request->toArray();

        $user->username = $data['username'] ?? $user->username;
        $user->email = $data['email'] ?? $user->email;
        $user->is_blocked = array_key_exists('block', $data); 

        $user->save();

        return to_route('adminUser');
    }

    public function deleteUser(Request $request) {

        $data = $request->toArray();
        if (!Auth::user()->is_admin) abort(401);

        $user = User::findOrFail(intval($data['id']));

        $user->email = sha1(rand());
        $user->username = sha1(rand());
        $user->password = sha1(rand());;
        $user->is_deleted = true;

        $user->save();
        
        return to_route('adminUser');
    }

    public function createProduct(Request $request) {
        if (!Auth::user()->is_admin) abort(401);

        $data = $request->toArray();

        $artist_name = trim($data['artist']);
        $artist = DB::table('artist')->where('name', 'ILIKE', '%' . $artist_name . '%')->first();

        if ($artist) 
            $artist_id = $artist->id;
        else {
            $new_artist = Artist::create(['name' => $artist_name]);
            $artist_id = $new_artist->id;
        }

        $price = $data['price']*100;
        Product::create([
            'artist_id' => $artist_id,
            'name' => $data['name'],
            'description' => $data['description'],
            'stock' => $data['stock'],
            'price' => $price,
            'format' => $data['format'],
            'year' => $data['year'],
            'description' => $data['description']
        ]);

        return to_route('adminProduct');
        
    }

    public function updateProduct(Request $request, $id) {
        if (!Auth::user()->is_admin) abort(401);

        $product = Product::findOrFail($id);
        if (!$product) {
            abort(404);
        }

        $data = $request->toArray();

        $product->stock = $data['stock'] ?? $product->stock;
        if ($data['price']) $product->price = $data['price']*100;
        $product->discount = $data['discount'] ?? $product->discount;

        $product->save();

        return to_route('adminProduct');
    } 

    public function deleteProduct(Request $request) {

        $data = $request->toArray();
        Product::findOrFail($data['product'])->delete();

        return to_route('adminProduct');
    }

    public function updateArtist(Request $request, int $id) {
        if (!Auth::user()->is_admin) abort(401);

        $artist = Artist::findOrFail($id);
        if (!$artist) {
            abort(404);
        }

        $data = $request->toArray();

        $artist->description = $data['message'] ?? $artist->description;

        $artist->save();

        return to_route('adminArtist');
    } 

    public function findUser() {
        // $users = User::search(request('search'))->paginate(20);

        // return view('pages.admin', ['users' => $users]);
    }
}
