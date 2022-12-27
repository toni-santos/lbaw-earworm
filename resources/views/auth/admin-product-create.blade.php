@include('partials.common.head', ['page' => "admin"])
<main>
        @include('partials.common.subtitle', ['title' => "Product Creation (Admin)"])

    <div id="forms-product-create-wrapper">
        <form id="forms-create" method="POST" action={{ route('adminCreateProductPost') }}>
        {{ csrf_field() }}
            <div id="forms-create-content">
                <section id="inputs-box-left" class="inputs-box-admin">
                    <div class="input-container">
                        <input class="text-input" type="text" name="name" autocomplete="off" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                        <label class="input-label" for="name">Name</label>
                    </div>
                    <div class="input-container">
                        <input id="artists-input" name="artist" class="text-input" type="text" list="artists" required>
                        <datalist id="artists">
                            @foreach ($artists as $artist)
                                <option>{{$artist->name}}</option>
                            @endforeach
                        </datalist>
                        <label class="input-label" for="artist">Artist</label>
                    </div>
                    <div class="input-container">
                        <input class="product-text-input" name="year" type="number" required>
                        <label class="product-input-label" for="year">Year</label>
                    </div>
                </section>
                <section id="inputs-box-right" class="inputs-box-admin">
                    <div class="input-container">
                        <input class="text-input" type="number" name="stock" onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                        <label class="input-label" for="stock">Stock</label>
                    </div>
                    <div class="input-container">
                        <input class="text-input" type="price" name="price" onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                        <label class="input-label" for="price">Stock</label>
                    </div>
                    <div class="input-container">
                        <select class="select-input" name="format">
                            <option value="CD" selected> CD </option> 
                            <option value="Vinyl"> Vinyl </option> 
                            <option value="Cassette"> Cassette </option> 
                            <option value="DVD"> DVD</option> 
                            <option value="Box Set"> Box Set </option> 
                        </select>
                        <label class="input-label" for="format">Format</label>
                    </div>
                </section>
                <div class="input-container">
                    <textarea class="text-input" name="description" placeholder=" " onkeyup="updateForm(event)" onfocus="checkFilled(event)" required>
                    </textarea>
                    <label class="input-label" for="description">Tracklist</label>
                </div>
            </div>
            <button class="confirm-button" id="confirm-button" type="submit" name="submit" value="Create">Create</button>
        </form>
    </div>
</main>
@include('partials.common.foot')