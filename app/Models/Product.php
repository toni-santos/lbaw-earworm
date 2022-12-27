<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps  = false;

  /**
   * The attributes that are mass assignable.
   *
   * @var array
   */
  protected $fillable = [
    'artist_id', 'name', 'genre', 'price', 'stock', 'format', 'year', 'description'
  ];

  public function scopeSearch($query, $search) {
    $sqlSearch = str_replace(' ', '%', $search);
    if($search ?? false) {
      return $query->whereRaw('tsvectors @@ plainto_tsquery(\'english\', ?)', $sqlSearch)
                  ->orderByRaw('ts_rank(tsvectors, plainto_tsquery(\'english\', ?)) DESC', $sqlSearch);
    }
  }

  public static function adminSearch($search) {
    if($search ?? false) {
      return Product::where('id', 'LIKE', "%{$search}%")
                  ->orWhere('name', 'ILIKE', "%{$search}%");
    }
}

  /**
   * The artist that authored this product.
   */
  public function artist() {
    return $this->belongsTo(Artist::class, 'artist_id');
  }

  /**
   * The genres that classify this product.
   */
  public function genres() {
    return $this->belongsToMany(Genre::class, 'product_genre', 'product_id', 'genre_id');
  }
  
  /**
   * The orders this product is associated with.
   */
  public function orders() {
    return $this->belongsToMany(Order::class, 'order_product', 'product_id', 'order_id')->withPivot('quantity');
  }

  /**
   * The products (and their quantities) that are in a client's wishlist.
   */
  public function inWishlist() {
    return $this->belongsToMany(User::class, 'wishlist', 'product_id', 'user_id');
  }

  /**
   * The reviews associated with this product.
   */
  public function reviews() {
    return $this->hasMany(Review::class, 'product_id');
  }

  /**
   * The table associated with the model.
   *
   * @var string
   */
  protected $table = 'product';
}
