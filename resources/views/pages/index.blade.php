<x-Head page="index"/>
<main>
    @include('partials.carousel', [
        'carouselTitle' => '',
        'carouselId' => 'carousel-promos',
        'promo' => true,
        'products' => []
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'Trending Products',
        'carouselId' => 'carousel-trending',
        'promo' => false,
        'products' => $trendingProducts
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'For You',
        'carouselId' => 'carousel-fy',
        'promo' => false,
        'products' => $fyProducts
    ])
</main>
<x-Foot/>