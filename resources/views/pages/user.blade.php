@include('partials.common.head', ['page' => "user"])
<main>
    <div id="user-banner">
        <div id="user-banner">
            <div id="user-top">
                <img src={{ $pfp }} alt="User Profile Picture" id="user-pfp">
                <div>
                    <p id="user-name">{{$user['username']}}</p>
                    <a id="user-settings-icon" href="{{route('editprofile', ['id' => Auth::id()])}}"><span class="material-icons">settings</span></a>            
                </div>
            </div>
        </div>
    </div>
    <div id="content-wrapper">
        <section id="reviews">
            @include('partials.common.subtitle', ['title' => "Reviews"])
            <div id="review-wrapper">
                @foreach ($reviews as $review)
                    @if (Auth::id() == $review['reviewer_id'])
                    @include('partials.common.review', ['type' => 'profile', 'review' => $review, 'edit' => true])
                    @else
                    @include('partials.common.review', ['type' => 'profile', 'review' => $review, 'edit' => false])
                    @endif
                @endforeach
            </div>
        </section>
        <section id="fav-artists">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Favorite Artists"])
            @if (count($favArtists) >= 5)
                @include('partials.common.carousel', [
                    'carouselTitle' => '',
                    'carouselId' => 'carousel-fav-artists',
                    'type' => 'artist',
                    'content' => $favArtists,
                    'wishlist' => ''
                ])
            @else
                @include('partials.common.static-carousel', [
                    'carouselTitle' => '',
                    'carouselId' => 'static-carousel-fav-artists',
                    'type' => 'artist',
                    'content' => $favArtists,
                    'wishlist' => ''
                ])
            @endif
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
            @if (count($recommendedProducts) >= 5)
            @include('partials.common.carousel', [
                'carouselTitle' => 'Last.fm Recommendations',
                'carouselId' => 'carousel-lastfm-recs',
                'type' => 'product',
                'content' => $recommendedProducts,
                'wishlist' => $wishlist
            ])
            @else
                @include('partials.common.static-carousel', [
                    'carouselTitle' => 'Last.fm Recommendations',
                    'carouselId' => 'static-carousel-lastfm-recs',
                    'type' => 'product',
                    'content' => $recommendedProducts,
                    'wishlist' => $wishlist
                ])
            @endif
        </section>
    </div>
</main>
@include('partials.common.foot')