<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps = false;

  protected $fillable = [
      'user_id', 'state'
  ];

  /**
     * The user this order belongs to.
     */
  public function user() {
    return $this->belongsTo(User::class, 'user_id', 'id');
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
  protected $table = 'orders';
}