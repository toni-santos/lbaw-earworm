<div class="user-top-{{$user->id}}" onclick="expandOptions(event, {{$user->id}})">
    <div class="user-info">
        <p>ID: {{$user->id}}</p>
        <p>Email: {{$user->email}}</p>
        <p>Username: {{$user->username}}</p>
        @if ($user->is_blocked)
        <p>Blocked</p>
        @endif
    </div>
    <div class="expand">
        <span class="material-symbols-outlined">expand_more</span>
    </div>
</div>
<div class="user-bot-{{$user->id}}" style="display:none;">
    <form method="POST" class="form-bot" action="{{route('adminedit', ['id' => $user->id])}}">
        {{ csrf_field() }}
        <section class="inputs-box">
            <div class="input-container">
                <input class="text-input" type="text" name="username" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                <label class="input-label" for="username">Name</label>
            </div>
            <div class="input-container">
                <input class="text-input" type="email" name="email" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                <label class="input-label" for="email">Email</label>
            </div>
            <div class="static-input">
                @if ($user->is_blocked)
                <input type="checkbox" name="block" checked>
                @else
                <input type="checkbox" name="block">
                @endif
                <label class="static-label" name="block" for="block">Block</label>
            </div>
        </section>
        <button class="confirm-button" type="submit">Change</button>
    </form>
    <form method="POST" class="form-bot" action="">
        <button class="confirm-button" type="submit">Delete</button>
    </form>
</div>
