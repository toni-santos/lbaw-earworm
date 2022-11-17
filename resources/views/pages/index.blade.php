<x-Head page="index"/>
<main>
    @include('partials.carousel', [
        'carouselTitle' => '',
        'carouselId' => 'carousel-promos',
        'promo' => true
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'Trending Products',
        'carouselId' => 'carousel-trending',
        'promo' => false
    ])
    @include('partials.carousel', [
        'carouselTitle' => 'For You',
        'carouselId' => 'carousel-fy',
        'promo' => false
    ])
</main>
<x-Foot/>