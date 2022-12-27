@include('partials.common.head', ['page' => "cart"])
<main>
    @if (session('cart'))
        <div id="payment-wrapper">
            <section id="items-wrapper">
                @foreach (session()->get('cart') as $id => $details)
                    @include('partials.cart.checkout-item', ['id' => $id, 'details' => $details])
                @endforeach
            </section>
            <aside id="payment-info">
                @include('partials.common.subtitle', ['title' => "Payment Information"])
                <div id="payment-description">
                    @foreach (session('cart') as $id => $details)
                        @include('partials.cart.item-price', ['id' => $id, 'details' => $details])
                    @endforeach
                </div>
                @if (Auth::check())
                    <div id="checkout-total">
                        <div class="checkout-subtitle">
                            <p>Total:</p>
                            <a class="subtitle1" id="checkout-value">0€</a>
                        </div>
                        <a class="confirm-button" href="{{route('checkout')}}"id="confirm-checkout">Proceed to checkout</a>
                    </div>
                @else 
                    <div id="checkout-total">
                        <div class="checkout-subtitle">
                            <p>Total:</p>
                            <a class="subtitle1" id="checkout-value">0€</a>
                        </div>
                        <a class="confirm-button" href="{{route('checkout')}}" id="confirm-checkout">Register to Buy</a>
                    </div>
                @endif
            </aside>
        </div>
    @else
        <div id="empty-cart-wrapper">
            <h2 id="empty-cart-text">Nothing in cart. <a>Time to change that!</a></h2>
            <a href="{{route('catalogue')}}">.<img id="empty-cart-catalogue-icon" src="/images/icons/compact-disc-solid.svg"></a>
        </div>
    @endif
</main>
@include('partials.common.foot')