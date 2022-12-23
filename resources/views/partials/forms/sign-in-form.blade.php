<form id="form-signup" method="POST" action= {{ route('authenticate') }}>
    {{ csrf_field() }}

    <section class="inputs-box">
        <div class="input-container">
            <input class="text-input" type="email" name="email" autocomplete="email" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="username" onclick="setFocus(event)">Email</label>
            <span class="required-alert">Required</span>
        </div>
        <div class="input-container">
            <input class="text-input" id="password-input" type="password" name="pwd" placeholder=" " autocomplete="current-password" minlength="8" onkeyup="updateForm(event); updateCounter(event)" onkeydown="updateCounter(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="pwd" onclick="setFocus(event)">Password</label>
            <span class="material-icons" id="password-eye" onclick="showPassword(event)">visibility</span>
            <span id="password-cnt">0/8</span>
            <span class="required-alert">Required</span>
        </div>
    </section>
    <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Signup" disabled>Sign In</button>
    <a href="{{route('register')}}" id="register-text">Not part of the clew yet? Register here!</a>
</form>
