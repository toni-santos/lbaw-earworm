@include('partials.common.head', ['page' => "admin", 'title' => ' - Artist Administration'])

<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Artist Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminArtist') }}">
            <input name="artist" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
    </div>
    <div id="result-list">
        @foreach ($artists as $artist)
            @include('partials.backoffice.artist-card', ['artist' => $artist])
        @endforeach
        {{ $artists->links('vendor.pagination.default') }}
    </div>
</main>
@include('partials.common.foot')