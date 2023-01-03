@include('partials.common.head', ['page' => 'artist', 'title' => " - " . $artist['name']])

<main>
    <div id="artist-banner">
        <div id="artist-top">
            <img src={{ $pfp }} alt="Artist Profile Picture" id="artist-pfp">
            @if ($favArtist)
            <div>
                <p id="artist-name">{{$artist['name']}}</p>
                <span id="favorite-artist-container-{{$artist['id']}}" class="material-icons fav-album" onclick="toggleArtistLike(event, {{$artist['id']}})">favorite</span>
            </div>
            @else
            <div>
                <p id="artist-name">{{$artist['name']}}</p>
                <span id="favorite-artist-container-{{$artist['id']}}" class="material-icons fav-album" onclick="toggleArtistLike(event, {{$artist['id']}})">favorite_outline</span>                
            </div>
            @endif
        </div>
    </div>
    @include('partials.common.subtitle', ['title' => 'Description'])
    <div id="artist-description">
        {{$artist['description']}}
    </div>
    @if (count($products) >= 5)
        @include('partials.common.carousel', [
            'carouselTitle' => 'From ' . $artist["name"],
            'carouselId' => 'carousel-artist',
            'type' => 'product',
            'content' => $products,
            'wishlist' => $wishlist
        ])
    @else
        @include('partials.common.static-carousel', [
            'carouselTitle' => 'From ' . $artist["name"],
            'carouselId' => 'static-carousel-artist',
            'type' => 'product',
            'content' => $products,
            'wishlist' => $wishlist
        ])
    @endif
</main>
@include('partials.common.foot')