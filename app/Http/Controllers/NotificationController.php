<?php

namespace App\Http\Controllers;

use App\Models\Notification;
use App\Models\User;
use App\Models\Product;
use App\Models\Order;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class NotificationController extends Controller
{
    // notif types: 'Order', 'Wishlist', 'Misc'

    public function showNotifications() {
        $user = User::findOrFail(Auth::id());
        if (!$user) to_route('login');

        $notifications = $user->notifications;
        foreach($notifications as $notif) {
            $notif['sent_at'] = date("d-m-Y H:i", strtotime($notif['sent_at']));
        }

        return view('pages.notification', ['notifications' => $notifications]);
    }

    static public function notifyWishlist(int $product_id, string $type) {
        if (!Auth::user()->is_admin) abort(403);
        $product = Product::findOrFail($product_id);
        if (!$product) abort(404);
        
        $users = $product->inWishlist;

        switch ($type) {
            case 'sale':
                foreach ($users as $user) {
                    Notification::insert([
                        'user_id' => $user->id,
                        'content_id' => $product->id,
                        'description' => "Your wishlisted item '$product->name'
                                          is $product->discount% off!",
                        'type' => "Wishlist"
                    ]);
                }
                break;
            case 'stock':
                foreach ($users as $user) {
                    Notification::insert([
                        'user_id' => $user->id,
                        'content_id' => $product->id,
                        'description' => "Your wishlisted item '$product->name'
                                          is back in stock!",
                        'type' => "Wishlist"
                    ]);
                }
                break;
            default:
                break;
        }

        return 200;
    }

    static public function notifyOrder(int $order_id, string $new_state) {
        if (!Auth::user()->is_admin) abort(403);
        $order = Order::findOrFail($order_id);
        if (!$order) abort(404);
        
        $user = $order->user;
        Notification::insert([
            'user_id' => $user->id,
            'description' => "Order #$order_id has been updated: $new_state!",
            'type' => "Order"
        ]);

        return 200;
    }

    static public function notifyMisc(string $message) {
        if (!Auth::user()->is_admin) abort(403);
        
        Notification::insert([
            'user_id' => $user->id,
            'description' => $message,
            'type' => "Misc"
        ]);

        return 200;
    }

}
