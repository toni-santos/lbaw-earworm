<?php use App\Http\Controllers\UploadController; ?>
@switch ($notif['type'])
    @case('Wishlist')
        <a href="{{route('product', ['id' => $notif['content_id']])}}" class="notification-item-{{$notif['id']}}">
            <img width="60px" height="60px" src={{ UploadController::getProductProfilePic($notif['content_id']) }} class="notification-img">
            <div class="notification-description">
                <p>{{$notif['description']}}</p>
            </div>
        </a>
        @break
    @case('Order')
        <a href={{route('order')}} class="notification-item-{{$notif['id']}}">
            <span class="material-icons notification-replacement">inventory_2</span>
            <div class="notification-description">
                <p>{{$notif['description']}}</p>
            </div>
        </a>
        @break
    @default
        <a href={{route('notification')}} class="notification-item-{{$notif['id']}}">
            <span class="material-icons notification-replacement">notifications</span>
            <div class="notification-description">
                <p>{{$notif['description']}}</p>
            </div>
        </a>
        @break
@endswitch