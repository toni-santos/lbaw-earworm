@include('partials.common.head', ['page' => "settings", 'title' => ' - Reset Password'])
<main id="main-wrapper">
    @include('partials.common.subtitle', ['title' => "Reset Password"])
    <form id="form-signup" method="POST" action= "{{ route('resetPassword')}}">
        {{ csrf_field() }}
        <section class="inputs-box">
            <div class="input-container">
                <input class="text-input" type="email" name="email" autocomplete="email" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                <label class="input-label" for="email" onclick="setFocus(event)">Account Email</label>
                <span class="required-alert">Required</span>
            </div>
            <div class="input-container">
                <input class="text-input" id="password-input" type="password" name="password" placeholder=" " autocomplete="current-password" minlength="8" onkeyup="updateForm(event); updateCounter(event)" onkeydown="updateCounter(event)" onfocus="checkFilled(event)" required>
                <label class="input-label" for="pwd" onclick="setFocus(event)">New Password</label>
                <span class="material-icons" id="password-eye" onclick="showPassword(event)">visibility</span>
                <span id="password-cnt">0/8</span>
                <span class="required-alert">Required</span>
            </div>
            <div class="input-container">
                <input class="text-input" id="confirm-password-input" type="password" name="password_confirmation" placeholder=" " autocomplete="current-password" minlength="8" onkeyup="updateForm(event); updateCounter(event)" onkeydown="updateCounter(event)" onfocus="checkFilled(event)" required>
                <label class="input-label" for="password_confirmation" onclick="setFocus(event)">Confirm Password</label>
                <span id="password-cnt">0/8</span>
                <span class="required-alert">Required</span>
            </div>
            <input name="token" value="{{$token}}" type=hidden>
        </section>
        <button class="confirm-button" id="confirm-button" type="submit" name="submit" disabled>Reset Password</button>
    </form>
</main>
@include('partials.common.foot')