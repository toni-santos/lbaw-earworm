<div class="nav-dropdowns" id="cart-dropdown">
    <p>Cart</p>
    <div id="cart-wrapper">
        @if (session('cart'))
            @foreach (session('cart') as $id => $details)
                @include('partials.cartitem', ['id' => $id, 'details' => $details])
            @endforeach
        @else
            <h2> Nothing in cart. </h2>
        @endif
    </div>
    <button id="cart-dropdown-purchase" type="submit">Purchase</button>
</div>
