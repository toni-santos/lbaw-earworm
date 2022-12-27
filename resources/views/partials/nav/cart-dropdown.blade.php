<div class="nav-dropdowns" id="cart-dropdown">
    <p>Cart</p>
    <div id="cart-wrapper">
        @if (session('cart'))
            @foreach (session('cart') as $id => $details)
                @include('partials.cart.cart-item', ['id' => $id, 'details' => $details])
            @endforeach
        @else
            <p class="dropdown-warning">Nothing in cart.</p>
        @endif
    </div>
    <a href="{{ route('cart')}}" class="nav-button"> Purchase </a>
</div>
