<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Http\Request;
use App\Models\Order;
use App\Models\OrderProduct;
use App\Models\Product;
use App\Http\Controllers\ProductController;

class OrderController extends Controller
{
    public function buy() {

        $cart = session()->get('cart');

        $next_possible_order_products = [];
        foreach ($cart as $id => $product) {

            $stock = Product::select('stock')->where('id', $id)->get()->toArray()[0]['stock'];

            if ($product['quantity'] > $stock) {
                return back(301, ["error" => "Not enough stock for order on ". $product['name']]);
            }
            
            $next_possible_order_products[$id] = $product;
            ProductController::removeFromCart($id);
            
        }

        $order = Order::create([
            'user_id' => Auth::id(),
            'state' => 'Processing'
        ]);

        foreach ($next_possible_order_products as $id => $product) {
            
            DB::table('order_product')->insert([
                'order_id' => $order->id,
                'product_id' => $id,
                'quantity' => $product['quantity']
            ]);
            
        }
        
        return to_route('home');
    }

    public function update(Request $request) {

        $data = $request->all();
        dd($data);

        $order = Order::where('id', intval($data['id']));
        $new_state = $data['state'];

        $order->state = $new_state;

        $order->save();
        return to_route('adminOrder');

    }

    public function getOrderProducts($order) {

        $order_products = $order->products;
        if (empty($order_products->toArray())) return [];

        $products_info = array();

        foreach ($order_products as $id => $product) {

            $product_quantity = OrderProduct::select('quantity')->where([
                'order_id' => $order->id,
                'product_id' => $product->id
            ])->get()->toArray()[0]['quantity'];

            $products_info[$id] = [
                'id' => $product->id,
                'artist_name' => $product->artist->name,
                'name' => $product->name,
                'quantity' => $product_quantity
            ];

        }

        $order['products'] = $products_info;
        return $order;

    }

    public function getAllOrderProducts() {

        $orders = Order::all();
        $orders_products = array();

        foreach ($orders as $order) {
            $orders_products[$order->id] = $this->getOrderProducts($order);
        }

        return $orders_products;
        
    }
}
