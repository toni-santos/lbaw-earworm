<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps  = false;

  /**
   * The product this review belongs to.
   */
  public function product() {
    return $this->belongsTo(Product::class, 'product_id');
  }

  /**
   * The user that reviewed this product.
   */
  public function writer() {
    return $this->belongsTo(User::class, 'user_id');
  }

  /**
   * The table associated with the model.
   *
   * @var string
   */
  protected $table = 'Review';
}