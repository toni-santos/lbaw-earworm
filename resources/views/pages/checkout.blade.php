@include('partials.common.head', ['page' => "checkout"])
<main>
    @if (Auth::check())
        <form method="POST" action="{{route('buy')}}">
    @else
        <form method="GET" action="{{route('login')}}">
    @endif
        {{ csrf_field() }}
        <div id="payment-wrapper">
            <section id="items-wrapper">
                @if (session()->get('cart'))
                    @foreach (session()->get('cart') as $id => $details)
                        @include('partials.cart.checkout-item', ['id' => $id, 'details' => $details])
                    @endforeach
                @else
                    <h2> Nothing in cart. </h2>
                @endif
            </section>
            <aside id="payment-info">
                @include('partials.common.subtitle', ['title' => "Payment Information"])
                <div id="payment-description">
                    @if (session('cart'))
                        @foreach (session('cart') as $id => $details)
                            @include('partials.cart.item-price', ['id' => $id, 'details' => $details])
                        @endforeach
                    @else
                        <h2> Nothing in cart. </h2>
                    @endif
                </div>
                @if (Auth::check())                    
                    <div id="billing-info">
                        @include('partials.common.subtitle', ['title' => "Billing Information"])
                        <input placeholder="Address" class="text-input" type="text" id="address" name="address" onkeyup="checkDone(event)" required>
                        <label class="input-label" for="address">Address</label>
                    </div>
                    <div id="payment-method">
                        @include('partials.common.subtitle', ['title' => "Payment Method"])
                        <input type="radio" class="radio" name="payment-method" id="mbway" value="mbway" checked required>
                        <label for="mbway" class="radio-label">MBWay</label>
                        <input type="radio" class="radio" name="payment-method" id="billing" value="billing" required>
                        <label for="billing" class="radio-label">Billing</label>
                    </div>
                    <div id="checkout-total">
                        <a class="subtitle1" id="checkout-value">0€</a>
                            <button type="submit" class="confirm-button" id="confirm-checkout" disabled>Confirm</button>
                @else 
                <div id="checkout-total">
                    <a class="subtitle1" id="checkout-value">0€</a>
                    <button type="submit" class="confirm-button" id="confirm-checkout">Register to Buy</button>
                </div>
                @endif
            </aside>
        </div>
    </form>
</main>
@include('partials.common.foot')