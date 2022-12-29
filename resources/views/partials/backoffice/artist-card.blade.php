<?php use App\Http\Controllers\UploadController; ?>
<div class="result-wrapper">
    <div class="result-top-{{$artist->id}}" onclick="expandOptions(event, {{$artist->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{UploadController::getArtistProfilePic($artist->id)}}>
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
        <div>
            <div id="artist-card-desc">
                <p> Description: <br> {{$artist->description}} </p>
            </div>
            <form method="POST" class="form-bot" action="{{route('adminUpdateArtist', ['id' => $artist->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <textarea placeholder="New description..." id="message" class="text-input" name="message" rows="6" cols="100"> {{$artist->description}} </textarea>
                    <button class="confirm-button" type="submit">Update description</button>
                </section>
            </form>
            <form method="POST" enctype="multipart/form-data" class="form-bot" action="{{route('adminUpdateArtistProfilePic', ['id' => $artist->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <input class="confirm-button" type="file" id="artist-pfp" name="artist-pfp">
                    <button class="confirm-button" type="submit">Change photo</button>
                </section>
            </form>

        </div>
    </div>
</div>
