<?php use App\Http\Controllers\UploadController; ?>
<div>
    <div class="result-top-{{$user->id}}" onclick="expandOptions(event, {{$user->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{UploadController::getUserProfilePic($user->id)}}>
            <div class="result-info">
                <p>ID: {{$user->id}}</p>
                <p>Email: {{$user->email}}</p>
                <p>Username: {{$user->username}}</p>
                @if ($user->is_blocked)
                <p>Blocked</p>
                @endif
            </div>
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

            <form method="POST" enctype="multipart/form-data" class="middle-form form-bot" action="{{route('adminUpdateUserProfilePic', ['id' => $user->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <label for="user-pfp-{{$user->id}}" class="upload-button">
                        <span class="material-icons">file_upload</span>File Upload
                    </label>
                    <input type="file" id="user-pfp-{{$user->id}}" name="user-pfp">
                </section>
                <button class="confirm-button" type="submit">Change photo</button>
            </form>
            
            <form method="POST" class="form-bot" action="{{route('adminDeleteUser', ['user' => $user])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>
        </div>
    </div>
    
</div>
