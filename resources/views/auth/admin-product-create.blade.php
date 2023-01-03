@include('partials.common.head', ['page' => "admin", 'title' => ' - Create Product'])
<main id="content-wrapper">
    <div id="side-image">

    </div>
    <div id="form-wrapper">
        @include('partials.common.subtitle', ['title' => "Product Creation (Admin)"])
        <form id="forms-create" method="POST" action={{ route('adminCreateProductPost') }}>
            {{ csrf_field() }}
            <section id="inputs-box-left">
                <div class="input-container">
                    <input class="text-input" type="text" name="name" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    <label class="input-label" for="name">Name</label>
                    <span class="required-alert">Required</span>
                </div>
                <div class="input-container">
                    <input id="text-input" name="artist" class="text-input" type="text" list="artists" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    <label class="input-label" for="artist">Artist</label>
                    <datalist id="artists">
                        @foreach ($artists as $artist)
                        <option>{{$artist->name}}</option>
                        @endforeach
                    </datalist>
                    <span class="required-alert">Required</span>
                </div>
                <div class="input-container">
                    <input class="text-input" name="year" type="number" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    <label class="input-label" for="year">Year</label>
                    <span class="required-alert">Required</span>
                </div>
            </section>
            <section id="inputs-box-right">
                <div class="input-container">
                    <input class="text-input" type="number" name="stock" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    <label class="input-label" for="stock">Stock</label>
                    <span class="required-alert">Required</span>
                </div>
                <div class="input-container">
                    <input class="text-input" type="price" name="price" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    <label class="input-label" for="price">Price</label>
                    <span class="required-alert">Required</span>
                </div>
                <div class="input-container">
                    <select class="select-input" name="format">
                        <option value="CD" selected> CD </option> 
                        <option value="Vinyl"> Vinyl </option> 
                        <option value="Cassette"> Cassette </option> 
                        <option value="DVD"> DVD</option> 
                        <option value="Box Set"> Box Set </option> 
                    </select>
                </div>
            </section>
            <section id="inputs-box-bottom">
                <div class="scroll-filter" id="filter-genre">
                    @foreach ($genres as $genre)
                    <label><input type="checkbox" class="checkbox" name="genre[]" value="{{$genre->name}}"><span class="genre-check">{{$genre->name}}</span></label>
                    @endforeach
                </div>
                <div class="input-container">
                    <textarea class="text-input tracklist-input" name="description" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required></textarea>
                    <label class="input-label tracklist" for="description">Tracklist</label>
                    <span class="required-alert">Required</span>
                </div>
                <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Create" disabled>Create</button>
            </section>
        </form>
    </div>
</main>
@include('partials.common.foot')