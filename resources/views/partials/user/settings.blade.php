<div class="user-top-{{$user->id}}" onclick="expandOptions(event, {{$user->id}})">
    <div class="user-info">
        <p>Email: {{$user->email}}</p>
        <p>Username: {{$user->username}}</p>
    </div>
    <div class="expand">
        <span class="material-symbols-outlined">expand_more</span>
    </div>
</div>
<div class="user-bot-{{$user->id}}" style="display:none;">
    <form method="POST" class="form-bot" action="{{route('editprofilepost', ['id' => $user->id])}}">
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
        </section>
        <button class="confirm-button" type="submit">Change</button>
    </form>
</div>
