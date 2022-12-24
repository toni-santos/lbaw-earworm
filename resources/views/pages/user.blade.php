@include('partials.common.head', ['page' => "user"])
<main>
    <div id="profile-header">
        <img id="profile-pic" src="https://picsum.photos/250/400?random=1">
        <p id="profile-name">{{ $user['username'] }}</p>
    </div>
    <section id="content-select">
        <div>
            <a href="#reviews">Reviews</a>
            <a href="#fav-artists">Favorite Artists</a>
            <a href="#buy-history">Purchase History</a>
            <a href="#lastfm-recs">Last.fm Recommendations</a>
        </div>
    </section>
    <div id="content-wrapper">
        <section id="reviews">
            @include('partials.common.subtitle', ['title' => "Reviews"])
            <div id="review-wrapper">
                @include('partials.user.review')
                @include('partials.user.review')
                @include('partials.user.review')
                @include('partials.user.review')
                @include('partials.user.review')
                @include('partials.user.review')
            </div>
        </section>
        <section id="fav-artists">
            @include('partials.common.carousel', [
                'carouselTitle' => 'User Favorite Artists',
                'carouselId' => 'carousel-fav-artists',
                'type' => 'artist',
                'content' => $favArtists
            ])
        </section>
        <section id="buy-history">
            @include('partials.common.subtitle', ['title' => "Purchase History"])
            <div id="buy-history-wrapper">
                @foreach ($purchaseHistory as $product)
                    @include('partials.user.buy-history', ['product' => $product])
                @endforeach
            </div>
        </section>
        <section id="lastfm-recs">
            @include('partials.common.carousel', [
                'carouselTitle' => 'Last.fm Recommendations',
                'carouselId' => 'carousel-lastfm-recs',
                'type' => 'product',
                'content' => $recommendedProducts,
                'wishlist' => $wishlist
            ])
        </section>
    </div>
</main>
@include('partials.common.foot')