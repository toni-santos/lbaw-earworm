@include('partials.common.head', ['page' => "wishlist"])
<main>
    @include('partials.common.subtitle', ['title' => 'Wishlist'])
    @foreach ($wishlist as $product)
        @include('partials.common.wishlist-card', ['product' => $product])
    @endforeach
</main>
@include('partials.common.foot')