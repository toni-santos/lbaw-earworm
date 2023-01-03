<?php use App\Http\Controllers\UploadController; ?>
<div class="result-wrapper">
    <div class="result-top-{{$artist->id}}" onclick="expandOptions(event, {{$artist->id}})">
        <div class="result-top-content">
            <img alt="Artist Profile Picture" class="result-img" src={{UploadController::getArtistProfilePic($artist->id)}}>
            <div class="result-info">
                <p>ID: {{$artist->id}}</p>
                <p>Name: {{$artist->name}}</p>
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$artist->id}}">
        <div class="form-bot-wrapper">
            <form method="POST" class="form-bot" action="{{route('adminUpdateArtist', ['id' => $artist->id])}}">
                <div id="artist-card-desc">
                    <p> Description: <br> {{$artist->description}} </p>
                </div>
                {{ csrf_field() }}
                <section class="inputs-box">
                    <textarea placeholder="New description..." id="message" class="text-input" name="message" rows="6" cols="100"> {{$artist->description}} </textarea>
                    <button class="confirm-button" type="submit">Update description</button>
                </section>
            </form>
            <form method="POST" enctype="multipart/form-data" class="form-bot" action="{{route('adminUpdateArtistProfilePic', ['id' => $artist->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <label for="artist-pfp-{{$artist->id}}" class="upload-button">
                        <span class="material-icons">file_upload</span>File Upload
                    </label>
                    <input type="file" id="artist-pfp-{{$artist->id}}" name="artist-pfp">
                </section>
                <button class="confirm-button" type="submit">Change photo</button>
            </form>

        </div>
    </div>
</div>
