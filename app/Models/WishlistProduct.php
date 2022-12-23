<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class WishlistProduct extends Model
{
    protected $table = "wishlist_product";

    protected $fillable = [
        'wishlist_id', 'product_id'
    ];

    public $timestamps = false;
}
