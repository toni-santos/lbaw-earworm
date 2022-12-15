<div class="nav-dropdowns" id="wishlist-dropdown">
    <p>Wishlist</p>
    <div id="wishlist-wrapper">
        @for ($i = 0; $i < 5; $i++)
            @include('partials.wishlist-item')
        @endfor
    </div>
</div>
