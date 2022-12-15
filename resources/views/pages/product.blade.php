@include('partials.common.head', ['page' => "product"])
<main id="content-wrapper">
    <div id="product-grid">
        <div id="product-img-wrapper">
            <img src={{ url('/images/products/' . $product['id'] . '.jpg') }} id="product-img">
        </div>
        <div class="product-description">
            <p id="product-name">{{$product->name}}</p>
            <p id="product-artist">{{$product->artist->name}}</p>
            <div id="genres-wrapper">
                @foreach ($genres as $genre)
                    <p class="product-genre">{{$genre['name']}}</p>
                @endforeach
            </div>
        </div>
        <div id="product-purchase">
            <p id="product-price">{{$product->price}} €</p>
            <button class="confirm-button">
                <a href="{{route('buyProduct', ['id' => $product->id])}}">BUY</a>
            </button>
        </div>
    </div>
    <div id="product-tracklist-wrapper">
        @include('partials.common.subtitle', ['title' => "Tracklist"])
        <div id="product-tracklist">
            <?php
                $arr = explode("\n", $product->description);
                foreach ($arr as $track) {?>
                <p class="track"><?= $track ?></p>
            <?php } ?>
        </div>
    </div>
    @include('partials.common.carousel', [
        'carouselTitle' => 'More like this...',
        'carouselId' => 'carousel-fy',
        'type' => 'product',
        'content' => $products
    ])
</main>
@include('partials.common.foot')