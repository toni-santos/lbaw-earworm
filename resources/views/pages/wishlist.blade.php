@include('partials.common.head', ['page' => "wishlist"])
<main>
    @include('partials.common.subtitle', ['title' => 'Wishlist'])
    <div id="wl-wrapper">
        @foreach ($wishlist as $product)
            @include('partials.common.wishlist-card', ['product' => $product])
        @endforeach
    </div>
</main>
@include('partials.common.foot')