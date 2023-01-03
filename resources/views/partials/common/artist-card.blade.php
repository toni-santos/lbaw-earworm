<?php use App\Http\Controllers\UploadController; ?>
<article class="artist-card">
    <a href="/artist/{{$artist['id']}}"><img alt="Artist Image" src={{ UploadController::getArtistProfilePic($artist['id']) }} class="artist-card-img"></a>
    <article class="artist-desc">
        <a href="/artist/{{$artist['id']}}" class="artist-name" title="Artist Name">{{$artist['name']}}</a>
    </article>
</article>