
<section id="nav-tags">
    <div style="background-image:url(https://images.unsplash.com/photo-1504711331083-9c895941bf81?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NHx8aW5mb3JtYXRpb258ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60);" id="info-tag"><div class="darken-tag"></div>Account Information</div>
    <div style="background-image:url(https://images.unsplash.com/photo-1633265486064-086b219458ec?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8cGFzc3dvcmR8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60);" id="password-tag"><div class="darken-tag"></div>Change Password</div>
    <div style="background-image:url(https://images.unsplash.com/photo-1458560871784-56d23406c091?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OXx8bXVzaWN8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60);" id="lastfm-tag"><div class="darken-tag"></div>Last.FM Connection</div>
</section>

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
        <div class="user-bot-info-edit-{{$user->id}}">
            <form method="POST" class="form-bot" action="{{route('editprofilepost', ['id' => $user->id])}}">
                <h2 class="zone-name">Account Information</h2>
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
            <form method="POST" enctype="multipart/form-data" class="upload-form form-bot" action="{{route('userProfilePic', ['id' => $user->id])}}">
                <h2 class="zone-name">Profile Picture</h2>
                {{ csrf_field() }}
                <section class="inputs-box">
                    <label for="user-pfp" class="upload-button">
                        <span class="material-icons">file_upload</span>File Upload
                    </label>
                    <input type="file" id="user-pfp" name="user-pfp">
                    <button class="confirm-button" type="submit">Change photo</button>
                </section>
            </form>
            <form method="POST" class="form-bot" action="{{route('deleteAccount', ['id' => $user->id])}}">
                <h2 class="zone-name">Delete Account</h2>
                {{ csrf_field() }}                    
                <button class="confirm-button" id="delete-account" type="submit">Delete</button>
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
        <div class="user-bot-pass-change-{{$user->id}}">
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

        <div class="user-top-pass-recover-{{$user->id}}" onclick="expandUserOptions(event, 'recover', {{$user->id}})"  id="recover-button">
            <div class="expand">
                <p> Recover Password </p>
                <span class="material-icons">expand_more</span>
            </div>
        </div>
        <div class="user-bot-pass-recover-{{$user->id}}">
            <form method="POST" class="form-bot" action="{{route('recoverPassword')}}">
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
        <div class="user-bot-lastfm-link-{{$user->id}}">
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