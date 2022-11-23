<?php

namespace App\Models;

use Illuminate\Notifications\Notifiable;
use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    use Notifiable;

    // Don't add create and update timestamps in database.
    public $timestamps  = false;

    /**
     * The attributes that are mass assignable.
     *
     * @var array
     */
    protected $fillable = [
        'username', 'email', 'password', 'is_admin'
    ];

    /**
     * The attributes that should be hidden for arrays.
     *
     * @var array
     */
    protected $hidden = [
        'password', 'remember_token',
    ];

    public function scopeSearch($query, $search) {
        //dd($search);
        if($search ?? false) {
          return $query->where('username', 'LIKE', "%{$search}")
                      ->orWhere('id', 'LIKE', "%{$search}%")
                      ->orWhere('email', 'LIKE', "%{$search}%");
        }
      }


    /**
     * The products this user has wishlisted.
     */
    public function wishlist() {
        return $this->belongsToMany(Product::class, 'wishlist_product', 'user_id', 'product_id');
    }

    /**
     * The artists this user has favourited.
     */
    public function favouriteArtists() {
        return $this->belongsToMany(Artist::class, 'fav_artist', 'user_id', 'artist_id');
    }

    /**
     * The orders this user has made.
     */
    public function orders() {
        return $this->hasMany(Order::class, 'user_id');
    }

    /**
   * The table associated with the model.
   *
   * @var string
   */
    protected $table = 'users';
}
