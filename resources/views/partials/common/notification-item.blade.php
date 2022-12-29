@switch ($item['type'])
    @case('product')
        <a href={{route('product', ['id' => $item['id']])}} class="notification-item-{{$item['id']}}">
            <img width="60px" height="60px" src={{ url('/images/products/' . $item['id'] . '.jpg') }} class="notification-img">
            <div class="notification-description">
                <p>Product is now on sale! Check it out!</p>
            </div>
        </a>
        @break
    @case('order')
        <a href={{route('order')}} class="notification-item-{{$item['id']}}">
            <span class="material-icons notification-replacement">inventory_2</span>
            <div class="notification-description">
                <p>Your order has been updated!</p>
            </div>
        </a>
        @break
    @default
        <a href={{route('order')}} class="notification-item-{{$item['id']}}">
            <span class="material-icons notification-replacement">notifications</span>
            <div class="notification-description">
                <p>Your order has been updated!</p>
            </div>
        </a>
        @break
@endswitch