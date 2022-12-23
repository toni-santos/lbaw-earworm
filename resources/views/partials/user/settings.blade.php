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
        <div class="user-top-info{{$user->id}}" onclick="expandUserOptions(event, {{$user->id}})">
            <div class="user-info">
                <p id="user-email">Email: {{$user->email}}</p>
                <p>Username: {{$user->username}}</p>
            </div>
            <div class="expand">
                <p> Change Account Details </p>
                <span class="material-symbols-outlined">expand_more</span>
            </div>
        </div>
        <div class="user-bot-info-{{$user->id}}" style="display:none;">
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
    </section>

    <section id="password-section" hidden>
        
        <div class="user-top-pass-{{$user->id}}" onclick="expandUserOptions(event, {{$user->id}})">
            <div class="expand">
                <p> Change Password </p>
                <span class="material-symbols-outlined">expand_more</span>
            </div>
        </div>
        <div class="user-bot-pass-{{$user->id}}" style="display:none;">
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

        <div class="user-bot-pass-recover-{{$user->id}}" style="display:flex">
            <form method="POST" class="form-bot" action="{{route('recoverpassword', ['id' => $user->id])}}">
                {{ csrf_field() }}                    
                <button class="confirm-button" type="submit">Recover Password</button>
            </form>
        </div>    

    </section>

    <section id="lastfm-section" hidden>
        <div class="user-top-lastfm-{{$user->id}}" onclick="expandUserOptions(event, {{$user->id}})">
            <div class="user-info">
                <p> Last.FM Account: *not linked* </p>
            </div>
            <div class="expand">
                <p> Link Last.FM Account </p>
                <span class="material-symbols-outlined">expand_more</span>
            </div>
        </div>
        <div class="user-bot-lastfm-{{$user->id}}" style="display:none;">
            <form method="POST" class="form-bot" action="">
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