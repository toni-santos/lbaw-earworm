@include('partials.common.head', ['page' => "catalogue"])

<main id="content-wrapper">
    <button id="collapsible"><span class="material-icons">filter_alt</span>Filters</button>
    <section id="filters">
        <!-- form to actually do stuff (in the future) -->
        <form id="filters-form" method="GET" action="{{ route('catalogue') }}">
            <fieldset id="filters-wrapper">
                <input type="hidden" name="search" id="hidden-search" value="{{request('search')}}">
                <!-- order: price rating alpha -->
                <select id="ord-filter" name="ord">
                    <option value="relevance">Relevance</option>
                    <option value="name-asc">Alphabetical Order</option>
                    <option value="price-asc">Ascending Price</option>
                    <option value="price-desc">Descending Price</option>
                    <option value="rating-asc">Ascending Rating</option>
                    <option value="rating-desc">Descending Rating</option>
                </select>
                <!-- filters: genre artist year price rating -->
                <p class="filter-title">Genre</p>
                <div class="scroll-filter" id="filter-genre">
                    @foreach ($genres as $genre)
                    @if (in_array($genre->name, $activeGenres))
                    <label><input type="checkbox" class="checkbox" name="genre[]" value="{{$genre->name}}" checked><span class="genre-check">{{$genre->name}}</span></label>
                    @else
                    <label><input type="checkbox" class="checkbox" name="genre[]" value="{{$genre->name}}"><span class="genre-check">{{$genre->name}}</span></label>
                    @endif
                    @endforeach
                </div>
                <p class="filter-title">Year</p>
                <div class="scroll-filter" id="filter-year">
                    @foreach ($years as $year)
                    @if (in_array($year, $activeYears)) 
                    <label><input type="checkbox" class="checkbox" name="year[]" value="{{$year}}" checked><span class="year-check">{{$year}}'s</span></label>
                    @else
                    <label><input type="checkbox" class="checkbox" name="year[]" value="{{$year}}"><span class="year-check">{{$year}}'s</span></label>
                    @endif
                    @endforeach
                </div>
                <p class="filter-title">Format</p>
                <div class="scroll-filter" id="filter-format">
                    @foreach ($formats as $format)
                    @if (in_array($format, $activeFormats))
                    <label><input type="checkbox" class="checkbox" name="format[]" value="{{$format}}" checked><span class="format-check">{{$format}}</span></label>
                    @else
                    <label><input type="checkbox" class="checkbox" name="format[]" value="{{$format}}"><span class="format-check">{{$format}}</span></label>
                    @endif
                    @endforeach
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