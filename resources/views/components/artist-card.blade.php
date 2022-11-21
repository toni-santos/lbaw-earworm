@props([
    'artist'
])

<div class="artist-card">
    <a href="/artist/{{$artist['id']}}"><img src="https://via.placeholder.com/200.png/"></a>
    <div class="artist-desc">
        <a href="/artist/{{$artist['id']}}" class="artist-name" title="Artist Name">{{$artist['name']}}</a>
    </div>
</div>