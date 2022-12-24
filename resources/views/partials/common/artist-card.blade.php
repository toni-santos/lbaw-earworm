<article class="artist-card">
    <a href="/artist/{{$artist['id']}}"><img src={{ url('/images/artists/' . $artist['id'] . '.jpg') }} class="artist-card-img"></a>
    <article class="artist-desc">
        <a href="/artist/{{$artist['id']}}" class="artist-name" title="Artist Name">{{$artist['name']}}</a>
    </article>
</article>