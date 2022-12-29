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

        return view('pages.notification', ['notifications' => $notifications]);
    }

    static public function notifySale(int $product_id) {
        if (!Auth::user()->is_admin) abort(403);
        $product = Product::findOrFail($product_id);
        if (!$product) abort(404);
        
        $users = $product->inWishlist;
        foreach ($users as $user) {
            Notification::insert([
                'user_id' => $user->id,
                'content_id' => $product->id,
                'description' => "Your wishlisted item $product->name
                                  is $product->discount% off!",
                'type' => "Wishlist"
            ]);
        }

        return 200;
    }
}
