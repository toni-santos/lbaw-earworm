<?php use App\Http\Controllers\UploadController; ?>
@switch ($notif['type'])
    @case('Wishlist')
        <a href="{{route('product', ['id' => $notif['content_id']])}}" class="notification-dropdown-item-{{$notif['id']}}">
            <img alt="Product Image" src={{ UploadController::getProductProfilePic($notif['content_id']) }} class="notification-dropdown-img">
            <div class="notification-dropdown-description">
                <p title="{{$notif['description']}}">{{$notif['description']}}</p>
            </div>
            <span class="material-icons notif-dropdown-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
        </a>
        @break
    @case('Order')
        <a href={{route('order')}} class="notification-dropdown-item-{{$notif['id']}}">
            <span class="material-icons notification-dropdown-replacement">inventory_2</span>
            <div class="notification-dropdown-description">
                <p>{{$notif['description']}}</p>
            </div>
            <span class="material-icons notif-dropdown-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
        </a>
        @break
    @default
        <a href={{route('notification')}} class="notification-dropdown-item-{{$notif['id']}}">
            <span class="material-icons notification-dropdown-replacement">notifications</span>
            <div class="notification-dropdown-description">
                <p>{{$notif['description']}}</p>
            </div>
            <span class="material-icons notif-dropdown-clear" onclick="clearNotification(event, {{$notif['id']}})"> clear </span>
        </a>
        @break
@endswitch