<x-Head page="index"/>
<main>
    @include('partials.carousel', [
        'carouselTitle' => '',
        'carouselId' => 'carousel-promos',
        'type' => 'promo',
        'content' => []
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'Trending Products',
        'carouselId' => 'carousel-trending',
        'type' => 'product',
        'content' => $trendingProducts
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'For You',
        'carouselId' => 'carousel-fy',
        'type' => 'product',
        'content' => $fyProducts
    ])
</main>
<x-Foot/>