@if (!Auth::check())
    {{-- {{ redirect(route('/')) }} --}}
@endif
<x-Head page="settings"/>
<main id="main-wrapper">
    <x-Subtitle title="Settings"/>
        @if (Auth::user()->is_admin)
        {{-- @if (1) --}}
            <form method="POST" action="">
                {{ csrf_field() }}
                
                <p>USER NAME</p>
                <p>USER ID</p>
                <p>Name: </p>
                <input type="text" name="username">
                <p>Email: </p>
                <input type="email" name="email">
                <fieldset>
                    <label>block</label>
                    <input type="checkbox" name="block">
                </fieldset>
                <button type="submit">SEND</button>
            </form>
        @else
        <div id="form-aux-wrapper">
            <div id="form-wrapper">
                <form method="POST"  action="{{route('editprofile', ['id' => $user->id])}}">
                    {{ csrf_field() }}
                    <section class="inputs-box">
                        <div class="input-container">
                            <input class="text-input" type="text" name="username" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                            <label class="input-label" for="username">Name</label>
                        </div>
                        <div class="input-container">
                            <input class="text-input" type="email" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                            <label class="input-label" for="email">Email</label>
                        </div>
                        
                    </section>
                    <button class="confirm-button" type="submit">Save</button>
                </form>
            </div>
            <div id="aux-wrapper">
                <p class="aux">Current username: {{$user['username']}}</p>
                <p class="aux">Current email: {{$user['email']}}</p>
            </div>
        </div>
        
        @endif

</main>
<x-Foot/>