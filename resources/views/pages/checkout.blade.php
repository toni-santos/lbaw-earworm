<x-Head page="checkout"/>
<main>
    <form method="POST" action="">
        <div id="payment-wrapper">
            <section id="items-wrapper">
                @for ($i = 0; $i < 5; $i++)
                    @include('partials.checkoutitem', ['id' => $i])
                @endfor
            </section>
            <aside id="payment-info">
                <x-Subtitle title="Payment Information" />
                <div id="payment-description">
                    @for ($i = 0; $i < 5; $i++)
                        @include('partials.itemprice', ['id' => $i])                    
                    @endfor
                </div>
                <div id="billing-info">
                    <x-Subtitle title="Billing Information" />
                    <input placeholder=" " class="text-input" type="text" id="address" name="address" onkeyup="checkDone(event)" required>
                    <label class="input-label" for="address">Address</label>
                </div>
                <div id="payment-method">
                    <x-Subtitle title="Payment Method" />
                    <label for="mbway" class="radio-label">
                    <input type="radio" class="radio" name="payment-method" id="mbway" value="mbway" onclick="checkDone(event)" required>MBWay</label>
                    <label for="billing" class="radio-label">
                    <input type="radio" class="radio" name="payment-method" id="billing" value="billing" onclick="checkDone(event)" required>Billing</label>
                </div>
                <div id="checkout-total">
                    <a class="subtitle1" id="checkout-value">0€</a>
                    <button type="submit" class="confirm-button" id="confirm-checkout" disabled>Confirm</button>
                </div>
            </aside>
        </div>
    </form>
</main>
<x-Foot/>