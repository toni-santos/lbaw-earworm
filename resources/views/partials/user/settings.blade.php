<div id="nav-wrapper">
    <nav id="user-nav-wide">
        <div class="nav-tags">
            <section id="info-tag"> <h1> Account Information </h1> </section>
            <section id="password-tag"> <h1> Change Password </h1> </section>
            <section id="lastfm-tag"> <h1> Last.FM Connection </h1> </section>
        </div>
    </nav>
</div>

<section id="settings-section"> 
    <section id="info-section" hidden>
        <div class="user-top-info-edit-{{$user->id}}" onclick="expandUserOptions(event, 'edit', {{$user->id}})">
            <div class="user-info">
                <p id="user-email">Email: {{$user->email}}</p>
                <p>Username: {{$user->username}}</p>
            </div>
            <div class="expand">
                <p> Change Account Details </p>
                <span class="material-icons">expand_more</span>
            </div>
        </div>
        <div class="user-bot-info-edit-{{$user->id}}" style="display:none;">
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
        <div class="user-bot-info-delete-{{$user->id}}" style="display:flex">
            <form method="POST" class="form-bot" action="{{route('deleteAccount', ['id' => $user->id])}}">
                {{ csrf_field() }}                    
                <button class="confirm-button" id="delete-account" type="submit">Delete Account</button>
            </form>
        </div>   
    </section>

    <section id="password-section" hidden>
        <div class="user-top-pass-change-{{$user->id}}" onclick="expandUserOptions(event, 'change', {{$user->id}})">
            <div class="expand">
                <p> Change Password </p>
                <span class="material-icons">expand_more</span>
            </div>
        </div>
        <div class="user-bot-pass-change-{{$user->id}}" style="display:none;">
            <form method="POST" class="form-bot" action="{{route('editpassword', ['id' => $user->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <div class="input-container">
                        <input class="text-input" type="password" name="old-password" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="old-password">Old Password</label>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="password" name="new-password" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="new-password">New Password</label>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="password" name="repeat-newpassword" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="repeat-new-password">Repeat New Password</label>
                    </div>
                </section>
                <button class="confirm-button" type="submit">Change</button>
            </form>
        </div>    

        <div class="user-top-pass-recover-{{$user->id}}" onclick="expandUserOptions(event, 'recover', {{$user->id}})">
            <div class="expand">
                <p> Recover Password </p>
                <span class="material-icons">expand_more</span>
            </div>
        </div>
        <div class="user-bot-pass-recover-{{$user->id}}" style="display:none">
            <form method="POST" class="form-bot" action="{{route('recoverPasswordPost', ['id' => $user->id])}}">
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
        </div>    

    </section>

    <section id="lastfm-section" hidden>
        <div class="user-top-lastfm-link-{{$user->id}}" onclick="expandUserOptions(event, 'link', {{$user->id}})">
            @if ($user->last_fm == NULL)
            <div class="user-info">
                <p> Last.FM Account: *not linked* </p>
            </div>
            @else
                <div class="user-info">
                    <p> Last.FM Account: {{$user->last_fm}} </p>
                </div>
            @endif
            <div class="expand">
                <p> Link Last.FM Account </p>
                <span class="material-icons">expand_more</span>
            </div>
        </div>
        <div class="user-bot-lastfm-link-{{$user->id}}" style="display:none;">
            <form method="POST" class="form-bot" action="{{route('loginLastFm')}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <div class="input-container">
                        <input class="text-input" type="text" name="username" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                        <label class="input-label" for="username">Last.FM Username</label>
                    </div>
                <button class="confirm-button" type="submit">Link</button>
            </form>
        </div>    
    </section>

</section>