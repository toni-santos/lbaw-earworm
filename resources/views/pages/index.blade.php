@include('partials.common.head', ['page' => "index"])
<main>
    @include('partials.common.promocard')
    {{-- @include('partials.common.carousel', [
        'carouselTitle' => '',
        'carouselId' => 'carousel-promos',
        'type' => 'promo',
        'content' => []
    ]) --}}
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
        @else
            @include('partials.common.static-carousel', [
                'carouselTitle' => 'For You',
                'carouselId' => 'static-carousel-fy',
                'type' => 'product',
                'content' => $fyProducts,
                'wishlist' => $wishlist
            ])
        @endif
    @else
        @include('partials.common.index-promos')'
    @endif
</main>
@include('partials.common.foot')