@include('partials.common.head', ['page' => "user"])
<main>
    <div id="user-banner">
        <div id="user-top">
            <img src={{ url('/images/artists/' . $user['id'] . '.jpg') }} alt="User Profile Picture" id="user-pfp">
            <p id="user-name">{{$user['username']}}</p>
            <a id="user-settings-icon" href="{{route('editprofile', ['id' => Auth::id()])}}"><span class="material-icons">settings</span></a>            
        </div>
    </div>
    <div id="content-wrapper">
        <section id="reviews">
            @include('partials.common.subtitle', ['title' => "Reviews"])
            <div id="review-wrapper">
                @foreach ($reviews as $review)
                    @include('partials.common.review', ['type' => 'profile', 'review' => $review])
                @endforeach
            </div>
        </section>
        <section id="fav-artists">
            @include('partials.common.subtitle', ['title' => $user['username'] . "'s Favorite Artists"])
            <div id="fav-artists-wrapper">
                @foreach ($favArtists as $artist)
                    @include('partials.common.artist-card', ['artist' => $artist])
                @endforeach
            </div>
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
                    'content' => $recommendedProducts,
                    'wishlist' => $wishlist
                ])
            @endif
        </section>
    </div>
</main>
@include('partials.common.foot')