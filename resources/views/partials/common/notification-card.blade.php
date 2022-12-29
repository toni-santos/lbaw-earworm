@switch ($notif['type'])
    @case('Wishlist')
        <a href={{route('product', ['id' => $notif['content_id']])}} class="notification-card-{{$notif['id']}}">
            <img width="60px" height="60px" src={{ url('/images/products/' . $notif['content_id'] . '.jpg') }} class="notification-img">
            <div class="notification-description">
                <p> {{$notif['description']}}</p>
            </div>
            <p> {{$notif['date']}} </p>
        </a>
        @break
    @case('Order')
        <a href={{route('order')}} class="notification-card-{{$notif['id']}}">
            <span class="material-icons notification-replacement">inventory_2</span>
            <div class="notification-description">
                <p>{{$notif['description']}}</p>
            </div>
            <p> {{$notif['date']}} </p>
        </a>
        @break
    @default
        <a class="notification-card-{{$notif['id']}}">
            <span class="material-icons notification-replacement">notifications</span>
            <div class="notification-description">
                <p> {{$notif['description']}}</p>
            </div>
            <p> {{$notif['date']}} </p>
        </a>
        @break
@endswitch