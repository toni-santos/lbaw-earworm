<article class="product-card">
    @if ($product->discount > 0)
    <span class="discount-label">-{{$product->discount}}%</span>
    @endif
    <a href="/product/{{$product['id']}}"><img class="product-card-img" src={{ url('/images/products/'.$product['id'].'.jpg') }}></a>
    <article class="product-desc">
        <a href="/product/{{$product['id']}}" class="prod-name" title="{{$product['name']}}">{{$product['name']}}</a>
        <a href="/artist/{{$product['artist_id']}}" class="prod-artist-name" title="Artist Name">{{$product['artist_name']}}</a>
        <article class="product-specs">
            <a class="prod-format" title="Format">{{$product['format']}}</a>
            <article class="product-fav-price">
                <div id="favorite-container-{{$product['id']}}">
                    @if (in_array($product['id'], $wishlist))
                    <span class="material-icons fav-album" onclick="toggleLike(event, {{$product['id']}})">favorite</span>
                    @else
                    <span class="material-icons fav-album" onclick="toggleLike(event, {{$product['id']}})">favorite_outline</span>
                    @endif
                </div>
                @if ($product->discount == 0)
                    <a title="Price">{{$product['price']}} €</a>
                @else
                    <a title="Price"><span class="cut-price">{{$product['price']}}</span> {{$product['discounted_price']}}€</a>
                @endif
            </article>
        </article>
    </article>
</article>