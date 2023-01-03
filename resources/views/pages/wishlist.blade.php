@include('partials.common.head', ['page' => "wishlist", 'title' => ' - Wishlist'])
<main>
    @if (count($wishlist) > 0)
    @include('partials.common.subtitle', ['title' => 'Wishlist'])
    <div id="wl-wrapper">
        @foreach ($wishlist as $product)
            @include('partials.common.wishlist-card', ['product' => $product])
        @endforeach
    </div>
    @else
    <div id="empty-wishlist-wrapper">
        <h2 id="empty-wishlist-text">Your wishlist is empty. <a href="{{route('catalogue')}}">Time to change that!</a></h2>
        <a href="{{route('catalogue')}}"><span id="empty-wishlist-icon" class="material-icons">favorite</span>
    </div>
    @endif
</main>
@include('partials.common.foot')