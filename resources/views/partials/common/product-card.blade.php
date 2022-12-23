<article class="product-card">
    <a href="/product/{{$product['id']}}"><img class="product-card-img" src={{ url('/images/products/'.$product['id'].'.jpg') }}></a>
    <article class="product-desc">
        <a href="/product/{{$product['id']}}" class="prod-name" title="{{$product['name']}}">{{$product['name']}}</a>
        <a href="/artists/{{$product['artist_id']}}" class="prod-artist-name" title="Artist Name">{{$product['artist_name']}}</a>
        <article class="product-specs">
            <a class="prod-format" title="Format">{{$product['format']}}</a>
            <article class="product-fav-price">
                <div id="favorite-container-{{$product['id']}}">
                    <span class="material-icons fav-album" onclick="toggleLike(event, {{$product['id']}})">favorite_outline</span>
                </div>
                <a title="Price">{{$product['price']}} €</a>
            </article>
        </article>
    </article>
</article>