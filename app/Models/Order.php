<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps  = false;

  /**
     * The user this order belongs to.
     */
  public function user() {
    return $this->hasOne(User::class, 'users', 'order_id', 'user_id');
  }

  /**
   * The user this order belongs to.
   */
  public function products() {
    return $this->belongsToMany(Product::class, 'order_product', 'order_id', 'product_id');
  }
  
  /**
   * The table associated with the model.
   *
   * @var string
   */
  protected $table = 'order';
}