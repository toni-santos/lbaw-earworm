<?php use App\Http\Controllers\UploadController; ?>
<div class="wishlist-card-top-{{$product['id']}}">
    <div class="wishlist-card-desc">
        <div>
            @if ($product['discount'] > 0)
            <span class="discount-label">-{{$product['discount']}}%</span>
            @endif
            <a href="/product/{{$product['id']}}">
                <img src={{ UploadController::getProductProfilePic($product['id']) }} class="wishlist-img">
            </a>
        </div>
        <div class="wishlist-card-specs">
            <div>
                <a href={{route('product', ['id' => $product['id']])}}>{{$product['name']}}</a>
                <a href={{route('artist', ['id' => $product['artist']])}}>{{$product['artist_name']}}</a>
                <p>{{$product['format']}}</p>
            </div>
            @if ($product['discount'] == 0)
                <p>{{$product['price']}} €</a>
            @else
                <p><span class="cut-price">{{$product['price']}}</span> {{$product['discounted_price']}}€</a>
            @endif
        </div>
    </div>
    <div class="favorite-container" id="favorite-container-{{$product['id']}}">
        <span id="" class="material-icons" onclick="toggleLike(event, {{$product['id']}})">favorite</span>
    </div>
</div>
