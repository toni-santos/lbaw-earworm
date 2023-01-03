<?php use App\Http\Controllers\UploadController; ?>
@switch ($notif['type'])
    @case('Wishlist')
        <a href={{route('product', ['id' => $notif['content_id']])}} class="notification-card-{{$notif['id']}}">
            <div class="notification-details">
                <img src={{ UploadController::getProductProfilePic($notif['content_id']) }} class="notification-img">
                <p>{{$notif['sent_at']}}</p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p title="{{$notif['description']}}">{{$notif['description']}}</p>
            </div>
        </a>
        @break
    @case('Order')
        <a href={{route('order')}} class="notification-card-{{$notif['id']}}">
            <div class="notification-details">
                <span class="material-icons notification-replacement">inventory_2</span>
                <p title="{{$notif['description']}}">{{$notif['sent_at']}}</p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p title="{{$notif['description']}}">{{$notif['description']}}</p>
            </div>
            
        </a>
        @break
    @case('Misc')
        <div class="notification-card-{{$notif['id']}}">
            <div class="notification-details">
                <span class="material-icons notification-replacement">notifications</span>
                <p> {{$notif['sent_at']}} </p>
            </div>
            <div class="notification-description">
                <span class="material-icons notif-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
                <p title="{{$notif['description']}}">{{$notif['description']}}</p>
            </div>
        </div>
        @break
    @default
        @break
@endswitch