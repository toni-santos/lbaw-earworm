@include('partials.common.head', ['page' => "settings"])
<main id="main-wrapper">
    @include('partials.common.subtitle', ['title' => "Recover Password"])
    <form id="form-signup" method="POST" action= "{{ route('recoverPasswordPost', ['id' => $user_id]) }}">
        <div class="input-desc">
            <p> In the email we sent you, you'll find a link to a page where you will be able to recover your password. </p>
        </div>
        {{ csrf_field() }}
        <section class="inputs-box">
            <div class="input-container">
                <input class="text-input" type="email" name="email" autocomplete="email" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                <label class="input-label" for="email" onclick="setFocus(event)">Email</label>
                <span class="required-alert">Required</span>
            </div>
        </section>
        <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Signup" disabled>Send Recovery Email</button>
    </form>
</main>
@include('partials.common.foot')