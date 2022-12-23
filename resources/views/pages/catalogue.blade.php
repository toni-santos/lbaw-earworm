@include('partials.common.head', ['page' => "catalogue"])
<main id="content-wrapper">
    <button id="collapsible"><span class="material-symbols-outlined">filter_alt</span>Filters</button>
        <section id="filters">
            <!-- form to actually do stuff (in the future) -->
            <form id="filters-form" method="GET" action={{ route('catalogue') }} onsubmit="return validateForm()">
                <fieldset id="filters-wrapper">
                    @if (!empty(request('search')))
                    <input type="hidden" name="search" value="{{request('search')}}">
                    @endif
                    <!-- order: price rating alpha -->
                    <select id="ord-filter" name="ord" id="ord-results">
                        <option value="alpha">Alphabetical Order</option>
                        <option value="asc-price">Ascending Price</option>
                        <option value="desc-price">Descending Price</option>
                        <option value="asc-rating">Ascending Rating</option>
                        <option value="desc-rating">Descending Rating</option>
                    </select>
                    <!-- filters: genre artist year price rating -->
                    <p class="filter-title">Genre</p>
                    <div class="scroll-filter" id="filter-genre">
                        @foreach ($genres as $genre)
                        <label><input type="checkbox" class="checkbox" name="genre[]" value="{{$genre->name}}"><span class="genre-check">{{$genre->name}}</span></label>
                        @endforeach
                    </div>
                    <p class="filter-title">Year</p>
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
                    <p class="filter-title">Artist</p>
                    <div class="scroll-filter" id="filter-artist">
                        <label><input type="checkbox" class="checkbox"><span class="artist-check">CD</span></label>
                        <label><input type="checkbox" class="checkbox"><span class="artist-check">Vinyl</span></label>
                        <label><input type="checkbox" class="checkbox"><span class="artist-check">Cassette</span></label>
                        <label><input type="checkbox" class="checkbox"><span class="artist-check">DVD</span></label>
                        <label><input type="checkbox" class="checkbox"><span class="artist-check">Box Set</span></label>
                    </div>
                    <p class="filter-title">Price</p>
                    <div class="box-filter" id="filter-price">
                        <label for="min-price">Min Price</label>
                        <input id="min-price" name="min-price" type="number" min="1" step="any" value={{request('min-price')}}>
                        <label for="max-price">Max Price</label>
                        <input id="max-price" name="max-price" type="number" min="1" step="any" value={{request('max-price')}}>
                    </div>
                    <p class="filter-title">Rating</p>
                    <div class="box-filter" id="filter-rating">
                        <label for="min-rating">Min Rating</label>
                        <input id="min-rating" name="min-rating" type="number" min="1" step="any" value={{request('min-rating')}}>
                        <label for="max-rating">Max Rating</label>
                        <input id="max-rating" name="max-rating" type="number" min="1" step="any" value={{request('max-rating')}}>
                    </div>
                </fieldset>
                <button type="submit" class="confirm-button">FILTER</button>
            </form>
        </section>
    <div class="results-wrapper">
        <section id="results">
            @if (!empty($products)) 
                @foreach ($products as $product)
                    @include('partials.common.product-card', ['product' => $product])
                @endforeach
            @else
                <p>No products correspond to your search!</p>
            @endif
        </section>
        {{ $products->links('vendor.pagination.default') }}
    </div>
</main>
@include('partials.common.foot')