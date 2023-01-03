@include('partials.common.head', ['page' => "index", 'title' => ''])

<main>
    @include('partials.common.promocard')
    @include('partials.common.carousel', [
        'carouselTitle' => 'Trending Products',
        'carouselId' => 'carousel-trending',
        'type' => 'product',
        'content' => $trendingProducts,
        'wishlist' => $wishlist
    ])
    @if (Auth::check())
        @if (count($fyProducts) >= 5)
            @include('partials.common.carousel', [
                'carouselTitle' => 'For You',
                'carouselId' => 'carousel-fy',
                'type' => 'product',
                'content' => $fyProducts,
                'wishlist' => $wishlist
            ])
        @elseif (count($fyProducts) < 5 && count($fyProducts) > 0)
            @include('partials.common.static-carousel', [
                'carouselTitle' => 'For You',
                'carouselId' => 'static-carousel-fy',
                'type' => 'product',
                'content' => $fyProducts,
                'wishlist' => $wishlist
            ])
        @elseif (count($fyProducts) == 0)
            @include('partials.common.subtitle', ['title' => "For You"])
            @include('partials.common.not-available', ['content' => "You aren't connected to Last.fm"])
        @endif
    @else
        @include('partials.common.index-promos')'
    @endif
</main>
@include('partials.common.foot')