<article class="nav-dropdowns" id="wishlist-dropdown">
    <p>Wishlist</p>
    <article id="wishlist-wrapper">
        @for ($i = 0; $i < 5; $i++)
            @include('partials.nav.wishlist-item')
        @endfor
    </article>
</article>
