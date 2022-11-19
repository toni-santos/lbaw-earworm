<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Artist extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps  = false;

  /**
   * The attributes that are mass assignable.
   *
   * @var array
   */
  protected $fillable = [
    'name'
  ];

  /**
   * The products that belong to this artist.
   */
  public function products() {
    return $this->hasMany(Product::class, 'product_id');
  }

  /**
   * The clients that have this artist in their favorites.
   */
  public function inFavorites() {
    return $this->belongsToMany(User::class, 'FavouriteArtist', 'product_id', 'user_id')->withPivot('quantity');
  }

  /**
   * The table associated with the model.
   *
   * @var string
   */
  protected $table = 'artist';
}
