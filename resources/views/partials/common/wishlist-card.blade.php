<div class="wishlist-card-top-{{$product['id']}}">
    <div class="wishlist-card-desc">
        <a href="/product/{{$product['id']}}"><img src={{ url('/images/products/'.$product['id'].'.jpg') }} class="wishlist-img"></a>
        <div class="wishlist-card-specs">
            <a href="/product/{{$product['id']}}">{{$product['name']}}</a>
            <p>{{$product['price']/100}} €</p>
        </div>
    </div>
    <div class="favorite-container" id="favorite-container-{{$product['id']}}">
        <span id="" class="material-icons" onclick="toggleLike(event, {{$product['id']}})">favorite</span>
    </div>
</div>
