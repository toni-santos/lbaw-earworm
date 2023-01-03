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
    public function buy(Request $request) {

        $cart = session()->get('cart');
        $data = $request->toArray();

        $next_possible_order_products = [];
        foreach ($cart as $id => $product) {
            $stock = Product::select('stock')->where('id', $id)->get()->toArray()[0]['stock'];

            if ($product['quantity'] > $stock) {
                return redirect()->route('cart')->withErrors(["stock" => "Not enough stock for order on ". $product['name'] . '.']);
            }
            
            $next_possible_order_products[$id] = $product;
            ProductController::removeFromCart($id);
            
        }

        $order = Order::create([
            'user_id' => Auth::id(),
            'address' => $data['address'],
            'payment_method' => $data['payment-method'],
            'state' => 'Processing'
        ]);

        foreach ($next_possible_order_products as $id => $product) {
            DB::table('order_product')->insert([
                'order_id' => $order->id,
                'product_id' => $id,
                'quantity' => $product['quantity'],
                'price' => $product['discounted_price']*100
            ]);
            
        }
        
        return to_route('order')->with(['message' => 'Checkout complete. Your order was created!']);
    }

    public function update(Request $request, int $id) {

        $data = $request->all();

        $new_state = $data['state'];
        $order = Order::where('id', $id)->update(['state' => $new_state]);

        NotificationController::notifyOrder($id, $new_state);

        return to_route('adminOrder')->with(['message' => 'Order updated!']);

    }

    public function adminCancel(int $id) {

        $order = Order::where('id', $id)->update(['state' => 'Canceled']);
        return to_route('adminOrder')->with(['message' => 'Order cancelled successfully!']);

    }

    public function userCancel(int $id) {

        $order = Order::where('id', $id)->update(['state' => 'Canceled']);
        return to_route('profile')>with(['message' => 'Order cancelled.']);

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

            $product_price = OrderProduct::select('price')->where([
                'order_id' => $order->id,
                'product_id' => $product->id
            ])->get()->toArray()[0]['price'];

            $product_price_float = ProductController::formatPrice($product_price / 100);

            $products_info[$id] = [
                'id' => $product->id,
                'artist_name' => $product->artist->name,
                'name' => $product->name,
                'quantity' => $product_quantity,
                'price' => $product_price_float
            ];

        }

        $order['products'] = $products_info;
        return $order;

    }

    public function getAdminOrderProducts(Request $request) {

        if (!(Auth::user() && Auth::user()->is_admin)) abort(403);
        $search = (array_key_exists('order', $request->toArray())) ? $request->toArray()['order'] : '';

        if ($search) {
            $orders = Order::where('id', 'LIKE', $search)
                            ->orWhere('user_id', 'LIKE', $search);
            $orders = $orders->paginate(20)->withQueryString();
        } else {
            $orders = Order::paginate(20)->withQueryString();
        }
        
        foreach($orders as $order) {
            $order = $this->getOrderProducts($order);
        }

        return view('pages.admin.orders', ['orders' => $orders]);

    }

    public function getUserOrderProducts() {

        if (!Auth::check()) abort(403);

        $orders = Auth::user()->orders;

        foreach($orders as $order) {
            $order = $this->getOrderProducts($order);
        }

        return view('pages.order', ['orders' => $orders]);

    }

}
