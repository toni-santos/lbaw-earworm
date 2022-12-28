<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Notification extends Model
{
    use HasFactory;

    public $timestamps = false;
    protected $table = 'notif';

    /**
     * The user this notification belongs to
     */
    public function user() {
        return $this->belongsTo(User::class, 'id', 'user_id');
    }
}
