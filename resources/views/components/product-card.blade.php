@props([
    'product'
])

<div class="product-card">
    <a href="/product/{{$product['id']}}"><img class="product-card-img" src={{ url('/images/products/'.$product['id'].'.jpg') }}></a>
    <div class="product-desc">
        <a href="/product/{{$product['id']}}" class="prod-name" title="Product Name">{{$product['name']}}</a>
        <a href="/artists/{{$product['artist_id']}}" class="prod-artist-name" title="Artist Name">{{$product['artist_name']}}</a>
        <div class="product-specs">
            <a class="prod-format" title="Format">{{$product['format']}}</a>
            <div class="product-fav-price">
                <span class="material-symbols-outlined">favorite</span>
                <a title="Price">{{$product['price']}} €</a>
            </div>
        </div>
    </div>
</div>