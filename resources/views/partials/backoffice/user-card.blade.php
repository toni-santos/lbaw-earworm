<div>
    <div class="result-top-{{$user->id}}" onclick="expandOptions(event, {{$user->id}})">
        <div class="result-info">
            <p>ID: {{$user->id}}</p>
            <p>Email: {{$user->email}}</p>
            <p>Username: {{$user->username}}</p>
            @if ($user->is_blocked)
            <p>Blocked</p>
            @endif
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$user->id}}">
        <div>
            <form method="POST" class="form-bot" action="{{route('adminUpdateUser', ['id' => $user->id])}}">
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
                        <label class="static-label" for="block-form">
                        @if ($user->is_blocked)
                        <input type="checkbox" name="block" id="block-form" checked>
                        @else
                        <input type="checkbox" name="block" id="block-form">
                        @endif
                        Block</label>
                    </div>
                </section>
                <button class="confirm-button" type="submit">Change</button>
            </form>
            <form method="POST" class="form-bot" action="{{route('adminDeleteUser', ['user' => $user])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>
        </div>
    </div>
    
</div>
