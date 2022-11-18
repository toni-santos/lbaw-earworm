<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
  // Don't add create and update timestamps in database.
  public $timestamps  = false;

    /**
   * The table associated with the model.
   *
   * @var string
   */
  protected $table = 'Order';
}