<div class="result-wrapper">
    <div class="result-top-{{$artist->id}}" onclick="expandOptions(event, {{$artist->id}})">
        <div class="result-top-content">
            <img class="result-img" src={{url('/images/artists/' . $artist['id'] . '.jpg')}}>
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
            <form method="POST" class="form-bot" action="{{route('adminUpdateArtist', ['id' => $artist->id])}}">
                {{ csrf_field() }}
                <section class="inputs-box">
                    <textarea placeholder=" " id="message" class="text-input" name="message" rows="6" cols="100">
                        {{$artist->description}}
                    </textarea>
                    <button class="confirm-button" type="submit">Change</button>
                </section>
            </form>
            <form method="POST" class="form-bot" action="{{route('adminDeleteArtist', ['artist' => $artist])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>
        </div>
    </div>
    
</div>
