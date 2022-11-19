@props([
    'product'
])

<div class="product-card">
    <a href="/products/{{$product['id']}}"><img src="https://via.placeholder.com/200.png/"></a>
    <div class="product-desc">
        <a href="/products/{{$product['id']}}" class="prod-name" title="Product Name">{{$product['name']}}</a>
        <a href="/artists/{{$product['artist_id']}}" class="prod-artist-name" title="Artist Name">{{$product['artist_name']}}</a>
        <div class="product-specs">
            <a class="prod-genres" title="Genres">Genres</a>
            <div class="product-fav-price">
                <span class="material-symbols-outlined">favorite</span>
                <a title="Price">Price</a>
            </div>
        </div>
    </div>
</div>