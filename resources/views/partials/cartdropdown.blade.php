<div class="nav-dropdowns" id="cart-dropdown">
    <p>Cart</p>
    <div id="cart-wrapper">
        @for ($i = 0; $i < 5; $i++)
            @include('partials.cartitem')
        @endfor
    </div>
    <button id="cart-dropdown-purchase" type="submit">Purchase</button>
</div>
