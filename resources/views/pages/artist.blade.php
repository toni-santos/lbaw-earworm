@include('partials.common.head', ['page' => 'artist'])
<main>
    <div id="artist-banner">
        <div id="artist-top">
            <img src={{ url('/images/artists/' . $artist['id'] . '.jpg') }} alt="Artist Profile Picture" id="artist-pfp">
            <p id="artist-name">{{$artist['name']}}</p>
        </div>
    </div>
    @include('partials.common.subtitle', ['title' => 'Description'])
    <div id="artist-description">
        {{$artist['description']}}
    </div>
    @if (count($products) >= 6)
        @include('partials.common.carousel', [
            'carouselTitle' => 'From ' . $artist["name"],
            'carouselId' => 'carousel-artist',
            'type' => 'product',
            'content' => $products
        ])
    @else
        @include('partials.common.static-carousel', [
            'carouselTitle' => 'From ' . $artist["name"],
            'carouselId' => 'static-carousel-artist',
            'content' => $products
        ])
    @endif
</main>
@include('partials.common.foot')