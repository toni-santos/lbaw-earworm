<form method="POST" class="form-bot" action="{{route('recoverPassword')}}">
    {{ csrf_field() }}           
    <section class="inputs-box">
        <div class="input-container">
            <input class="text-input" type="email" name="email" autocomplete="email" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="email" onclick="setFocus(event)">Email</label>
            <span class="required-alert">Required</span>
        </div> 
    </section>
    <button class="confirm-button" id="recover-password" type="submit">Send Recovery Email</button>
</form>