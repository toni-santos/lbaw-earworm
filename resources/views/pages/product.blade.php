@include('partials.common.head', ['page' => "product"])
<main id="content-wrapper">
    <div id="product-grid">
        <div id="product-img-wrapper">
            <img src={{ url('/images/products/' . $product['id'] . '.jpg') }} id="product-img" class="tilt">
        </div>
        <div class="product-description">
            <div>
                <p id="product-name">{{$product->name}}</p>
                <a href="/artist/{{$product['artist_id']}}" id="product-artist">{{$product->artist->name}}</a>
                @if ($product->rating)
                    <p id="rating">{{$product->rating}}/5<span class="material-icons" style="color:var(--star);">star</span></p>                    
                @else
                    <p id="rating">N/A<span class="material-icons" style="color:var(--star);">star</span></p>
                @endif
            </div>
            <div id="genres-wrapper">
                @foreach ($genres as $genre)
                    <p class="product-genre">{{$genre['name']}}</p>
                @endforeach
            </div>
        </div>
        <div id="product-purchase">
            <p id="product-price">{{$product->price}} €</p>
            @include('partials.common.stock', ['stock' => $product->stock])
            @if ($product->stock > 0)
            <form id="buy-form" action="{{route('buyProduct', ['id' => $product->id])}}">
                <button type=submit class="confirm-button">BUY</button>
            </form>
                @if (in_array($product['id'], $wishlist))
                    <p class="wishlist-container" id="favorite-container-{{$product->id}}" onclick="toggleLike(event, {{$product['id']}})">Wishlisted<span class="material-icons fav-album">favorite</span>
                @else
                    <p class="wishlist-container" id="favorite-container-{{$product->id}}" onclick="toggleLike(event, {{$product['id']}})">Add to Wishlist<span class="material-icons fav-album">favorite_outline</span>
                @endif
                    </p>
            @else
            <button class="confirm-button" href="{{route('buyProduct', ['id' => $product->id])}}" disabled>BUY</button>
            @endif
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
    @include('partials.common.subtitle', ['title' => "Reviews"])
    {{-- @if (Auth::check()) --}}
    <div id="reviews-wrapper">
        <form method="POST" action="../actions/add_review_action.php" id="review-form">
            {{-- TODO: USER IMAGE HERE --}}
            <div class="textarea-container">
                <textarea placeholder=" " id="message" class="text-input" name="message" rows="3" cols="100"></textarea>
                <label class="input-label" for="message">Review</label>
            </div>
            <div id="stars-button-container">
                <div class="star-container">
                    <?php for ($i = 0; $i < 5; $i++) { ?>
                        <input class="star input-star" type="radio" name="rating-star" id="star-<?= $i ?>" value="<?= $i+1 ?>" required>
                            <label id="star-label-<?= $i ?>" onclick="selectStar(event)">
                                <span class="material-icons">
                                    star_outline
                                </span>
                            </label>
                    <?php } ?>
                </div>
                <button class="review-button" type="submit" value="Submit">Review</button>
            </div>
        </form>
        <section id="reviews">
            @foreach ($reviews as $review)
                @include('partials.common.review', ['type' => "product", 'review' => $review])                
            @endforeach
        </section>
    </div>

    {{-- @endif --}}
    <section id="reviews">
    </section>
    @include('partials.common.carousel', [
        'carouselTitle' => 'More like this...',
        'carouselId' => 'carousel-product',
        'type' => 'product',
        'content' => $products,
        'wishlist' => $wishlist
    ])
</main>
@include('partials.common.foot')