<x-Head page="catalogue"/>
<main id="content-wrapper">
    <section id="filters">
        <!-- form to actually do stuff (in the future) -->
        <form id="filters-form">
            <fieldset id="filters-wrapper">
                <!-- order: price rating alpha -->
                <select id="ord-filter" name="ord" id="ord-results">
                    <option value="alpha">Alphabetical Order</option>
                    <option value="asc-price">Ascending Price</option>
                    <option value="desc-price">Descending Price</option>
                    <option value="asc-rating">Ascending Rating</option>
                    <option value="desc-rating">Descending Rating</option>
                </select>
                <!-- filters: genre artist year price rating -->
                <p>Genre</p>
                <div class="scroll-filter" id="fiter-genre">
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="genre-check">GENRE</span></label>
                </div>
                <p>Year</p>
                <div class="scroll-filter" id="filter-year">
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="year-check">YEAR</span></label>
                </div>
                <p>Artist</p>
                <div class="scroll-filter" id="filter-artist">
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                    <label><input type="checkbox" class="checkbox"><span class="artist-check">ARTIST</span></label>
                </div>
                <p>Price</p>
                <div class="box-filter" id="filter-price">
                    <label for="min-price">Min Price</label>
                    <input id="min-price" name="min-price" type="number" min="1" step="any">
                    <label for="max-price">Max Price</label>
                    <input id="max-price" name="max-price" type="number" min="1" step="any">
                </div>
                <p>Rating</p>
                <div class="box-filter" id="filter-rating">
                    <label for="min-rating">Min Rating</label>
                    <input id="min-rating" name="min-rating" type="number" min="1" step="any">
                    <label for="max-rating">Max Rating</label>
                    <input id="max-rating" name="max-rating" type="number" min="1" step="any">
                </div>
            </fieldset>
        </form>
    </section>
    <section id="results">
        @foreach ($products as $product)
            <x-ProductCard :product="$product"/>
        @endforeach
    </section>
</main>
<x-Foot/>