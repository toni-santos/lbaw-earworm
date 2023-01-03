@include('partials.common.head', ['page' => "user", 'title' => " - " . $user['username']])
<main>
    <div id="user-banner">
        <div id="user-banner">
            <div id="user-top">
                <img src={{ $pfp }} alt="User Profile Picture" id="user-pfp">
                <div>
                    <p id="user-name">{{$user['username']}}</p>
                    @if (Auth::id() == $user['id'])
                    <a id="user-settings-icon" href="{{route('editprofile', ['id' => Auth::id()])}}"><span class="material-icons">settings</span></a>            
                    @endif
                </div>
            </div>
        </div>
    </div>
    <div id="content-wrapper">
        @if (Auth::check() && (Auth::user()->is_admin || (Auth::id() == $user['id'])))
        <section id="buy-history">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Buy History"])
            @if (count($buyHistory) > 0)
                <div class="buy-history-wrapper">
                    @foreach ($buyHistory as $product)
                        @include('partials.common.buy-history', ['product' => $product])
                    @endforeach
                </div>
            @else
            @include('partials.common.not-available', ['content' => $user['username'] . " hasn't made any purchases yet"])
            @endif
        </section>
        @endif
        <section id="reviews">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Reviews"])
            @if (count($reviews) > 0)
            <div id="review-wrapper">
                @foreach ($reviews as $review)
                    @if (Auth::id() == $review['reviewer_id'])
                    @include('partials.common.review', ['type' => 'profile', 'review' => $review, 'edit' => true])
                    @else
                    @include('partials.common.review', ['type' => 'profile', 'review' => $review, 'edit' => false])
                    @endif
                @endforeach
            </div>
            @else
            @include('partials.common.not-available', ['content' => "There aren't any reviews"])
            @endif
        </section>
        <section id="fav-artists">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Favorite Artists"])
            @if (count($favArtists) > 0)
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
            @else
            @include('partials.common.not-available', ['content' => "There aren't any favorited artists"])
            @endif
        </section>
        <section id="wishlist-display">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Wishlist"])
            @if (count($wishlistProducts) > 0)
            @if (count($wishlistProducts) >= 5)
            @include('partials.common.carousel', [
                'carouselTitle' => '',
                'carouselId' => 'carousel-wishlist',
                'type' => 'product',
                'content' => $wishlistProducts,
                'wishlist' => $wishlist
            ])
            @else
                @include('partials.common.static-carousel', [
                    'carouselTitle' => '',
                    'carouselId' => 'static-carousel-wishlist',
                    'type' => 'product',
                    'content' => $wishlistProducts,
                    'wishlist' => $wishlist
                ])
            @endif
            @else
            @include('partials.common.not-available', ['content' => "The wishlist is empty"])
            @endif
        </section>
        <section id="lastfm-recs">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Recommendations"])
            @if (count($recommendedProducts) > 0)
            @if (count($recommendedProducts) >= 5)
            @include('partials.common.carousel', [
                'carouselTitle' => '',
                'carouselId' => 'carousel-lastfm-recs',
                'type' => 'product',
                'content' => $recommendedProducts,
                'wishlist' => $wishlist
            ])
            @else
                @include('partials.common.static-carousel', [
                    'carouselTitle' => '',
                    'carouselId' => 'static-carousel-lastfm-recs',
                    'type' => 'product',
                    'content' => $recommendedProducts,
                    'wishlist' => $wishlist
                ])
            @endif
            @else
            @include('partials.common.not-available', ['content' => "Not connected to Last.fm"])
            @endif
        </section>
    </div>
</main>
@include('partials.common.foot')