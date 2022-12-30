<?php use App\Http\Controllers\UploadController; ?>
@switch ($notif['type'])
    @case('Wishlist')
        <a href={{route('product', ['id' => $notif['content_id']])}} class="notification-card-{{$notif['id']}}">
            <div class="notification-details">
                <img width="60px" height="60px" src={{ UploadController::getProductProfilePic($notif['content_id']) }} class="notification-img">
                <p> {{$notif['sent_at']}} </p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p> {{$notif['description']}}</p>
            </div>
        </a>
        @break
    @case('Order')
        <a href={{route('order')}} class="notification-card-{{$notif['id']}}">
            <div class="notification-details">
                <span class="material-icons notification-replacement">inventory_2</span>
                <p> {{$notif['sent_at']}} </p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p>{{$notif['description']}}</p>
            </div>
            
        </a>
        @break
    @case('Misc')
        <a class="notification-card-{{$notif['id']}}" style="pointer-events: none; cursor: default;">
            <div class="notification-details">
                <span class="material-icons notification-replacement">inventory_2</span>
                <p> {{$notif['sent_at']}} </p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p>{{$notif['description']}}</p>
            </div>
        </a>
        @break
    @default
        @break
@endswitch