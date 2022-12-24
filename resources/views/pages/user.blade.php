@include('partials.common.head', ['page' => "user"])
<main>
    <div id="user-banner">
        <div id="user-top">
            <img src={{ url('/images/artists/' . $user['id'] . '.jpg') }} alt="User Profile Picture" id="user-pfp">
            <p id="user-name">{{$user['username']}}</p>
        </div>
    </div>
    <div id="content-wrapper">
        <section id="reviews">
            @include('partials.common.subtitle', ['title' => "Reviews"])
            <div id="review-wrapper">
                @include('partials.common.review', ['type' => 'profile'])
            </div>
        </section>
        <section id="fav-artists">
            @if ($favArtists >= 6)
            @include('partials.common.carousel', [
                'carouselTitle' => 'User Favorite Artists',
                'carouselId' => 'carousel-fav-artists',
                'type' => 'artist',
                'content' => $favArtists
            ])
            @elseif ($favArtists > 0)
            @include('partials.common.static-carousel', [
                'carouselTitle' => $user['username'] . ' Favorite Artists',
                'carouselId' => 'static-carousel-fav-artists',
                'type' => 'artist',
                'content' => $favArtists
            ])
            @else
            @include('partials.common.subtitle', ['title' => $user['username'] . ' Favorite Artists'])
            <p>No favorite artists yet...</p>
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