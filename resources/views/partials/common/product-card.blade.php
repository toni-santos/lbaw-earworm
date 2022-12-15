<article class="product-card">
    <a href="/product/{{$product['id']}}"><img class="product-card-img" src={{ url('/images/products/'.$product['id'].'.jpg') }}></a>
    <article class="product-desc">
        <a href="/product/{{$product['id']}}" class="prod-name" title="Product Name">{{$product['name']}}</a>
        <a href="/artists/{{$product['artist_id']}}" class="prod-artist-name" title="Artist Name">{{$product['artist_name']}}</a>
        <article class="product-specs">
            <a class="prod-format" title="Format">{{$product['format']}}</a>
            <article class="product-fav-price">
                <span class="material-symbols-outlined">favorite</span>
                <a title="Price">{{$product['price']}} €</a>
            </article>
        </article>
    </article>
</article>