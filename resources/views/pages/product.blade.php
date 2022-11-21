<x-Head page="product"/>
<main id="content-wrapper">
    <div id="product-grid">
        <div id="product-img-wrapper">
            <img src="https://picsum.photos/300/300?random=1" id="product-img">
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
            <div id="amnt-select">
                <a>-</a>
                <p>1</p>
                <a>+</a>
            </div>
            <button class="confirm-button">BUY</button>
        </div>
    </div>
    <div id="product-tracklist-wrapper">
        <x-Subtitle title="Tracklist"/>
        <div id="product-tracklist">
            <?php
                $arr = explode("\n", $product->description);
                foreach ($arr as $track) {?>
                <p class="track"><?= $track ?></p>
            <?php } ?>
        </div>
    </div>
    @include('partials.carousel', [
        'carouselTitle' => 'More like this...',
        'carouselId' => 'carousel-fy',
        'type' => 'product',
        'content' => $products
    ])
</main>
<x-Foot/>