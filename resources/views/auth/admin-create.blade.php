@extends('layouts.sign')
@section('content')
<form id="form-signup" method="POST" action={{ route('adminCreateAction') }}>
    {{ csrf_field() }}
    <x-Subtitle title="User Creation (Admin)"/>

    <section id="inputs-box" class="inputs-box-admin">
        <div class="input-container">
            <input class="text-input" type="text" name="username" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="username" onclick="setFocus(event)">Username</label>
            <span class="required-alert">Required</span>
        </div>
        <div class="input-container">
            <input class="text-input" type="email" name="email" autocomplete="email" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="email" onclick="setFocus(event)">Email</label>
            <span class="required-alert">Required</span>
        </div>
        <div class="input-container">
            <input class="text-input" id="password-input" type="password" name="pwd" placeholder=" " autocomplete="current-password" minlength="8" onkeyup="updateForm(event); updateCounter(event)" onkeydown="updateCounter(event)" onfocus="checkFilled(event)" required>
            <label class="input-label" for="pwd" onclick="setFocus(event)">Password</label>
            <span class="material-symbols-outlined" id="password-eye" onclick="showPassword(event)">visibility</span>
            <span id="password-cnt">0/8</span>
            <span class="required-alert">Required</span>
        </div>
        <div class="static-input">
            <input type="checkbox" name="admin">
            <label class="static-label" name="admin" for="admin">Admin</label>
        </div>
    </section>
    <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Create" disabled>Create</button>
</form>
@endsection
