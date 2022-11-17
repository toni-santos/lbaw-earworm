<x-Head page="checkout"/>
<main>
    <form method="POST" action="../actions/checkout_action.php">
        <div id="payment-wrapper">
            <section id="items-wrapper">
                @for ($i = 0; $i < 5; $i++)
                    @include('partials.checkoutitem', ['id' => $i])
                @endfor
            </section>
            <aside id="payment-info">
                <div id="payment-description">
                    @for ($i = 0; $i < 5; $i++)
                        @include('partials.itemprice', ['id' => $i])                    
                    @endfor
                </div>
                <div id="payment-method">
                    <p class="h6 payment-header">Payment Method</p>
                    <label for="inperson" class="subtitle2 dark-bg"><input type="radio" name="payment-method" id="inperson" value="inperson" checked>In Person</label>
                    <label for="online" class="subtitle2 dark-bg"><input type="radio" name="payment-method" id="online" value="online" disabled>Online (Coming Soon)</label>
                    <a class="subtitle1" id="cart-total">0€</a>
                    <button type="submit" class="subtitle1 shadow pointer" id="confirm-cart">Confirm</button>
                </div>
            </aside>
        </div>
    </form>
</main>
<x-Foot/>