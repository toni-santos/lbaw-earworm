@include('partials.common.head', ['page' => "checkout"])
<main>
    <div id="checkout-wrapper">
        <form id="checkout-form" method="POST" action="{{route('buy')}}">
            {{ csrf_field() }}
            @include('partials.common.subtitle', ['title' => "Billing Information"])
            <div id="billing-information">
                <section class="inputs-box">
                    <!--
                        div first name last name div
                        div country city zip code div
                        (flex-direction: row)
                        media query: flex-direction: column?
                    -->
                    <div class="multiple-input-row">
                        <div class="input-container">
                            <input class="text-input" type="text" name="first-name" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                            <label class="input-label" for="first-name" onclick="setFocus(event)">First Name</label>
                            <span class="required-alert">Required</span>
                        </div>
                        <div class="input-container">
                            <input class="text-input" type="text" name="last-name" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                            <label class="input-label" for="last-name" onclick="setFocus(event)">Last Name</label>
                            <span class="required-alert">Required</span>
                        </div>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="text" name="address" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                        <label class="input-label" for="address" onclick="setFocus(event)">Address</label>
                        <span class="required-alert">Required</span>
                    </div>
                    <div class="multiple-input-row">
                        <div class="input-container">
                            <select class="select-input" id="select-dropdown" type="text" name="country" placeholder=" " onkeyup="updateForm(event)" onclick="checkSelectFilled(event)" required>
                                <option></option>
                                @foreach ($countries as $country)
                                    <option class="select-option" name="country" value="{{$country['name']['common']}}">{{$country['name']['common']}}</option>
                                @endforeach
                            </select>
                            <label class="input-label" for="country" onclick="setFocus(event)">Country</label>
                            <span class="required-alert">Required</span>
                        </div>
                        <div class="input-container">
                            <input class="text-input" type="text" name="city" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                            <label class="input-label" for="city" onclick="setFocus(event)">City</label>
                            <span class="required-alert">Required</span>
                        </div>
                        <div class="input-container">
                            <input class="text-input" type="text" name="zip-code" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                            <label class="input-label" for="zip-code" onclick="setFocus(event)">ZIP Code</label>
                            <span class="required-alert">Required</span>
                        </div>
                    </div>
                </section>
            </div>
            @include('partials.common.subtitle', ['title' => "Payment Method"])
            <section class="inputs-box">
                <div class="input-container">
                    <input type="radio" class="radio" name="payment-method" id="mbway" value="mbway" checked required>
                    <label for="mbway" class="radio-label">MBWay</label>
                    <input type="radio" class="radio" name="payment-method" id="billing" value="billing" required>
                    <label for="billing" class="radio-label">Billing</label>
                </div>
            </section>
            <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Buy" disabled>Buy</button>
        </form>       
    </div>
</main>
@include('partials.common.foot')