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
    @include('partials.common.carousel', [
        'carouselTitle' => 'For You',
        'carouselId' => 'carousel-fy',
        'type' => 'product',
        'content' => $fyProducts,
        'wishlist' => $wishlist
    ])
    {{-- 
    TODO: NOT AUTHENTICATED STORE PROMO

    @if (Auth::check())
    @else
    @include('partials.common.index-promos')'
    @endif --}}
</main>
@include('partials.common.foot')