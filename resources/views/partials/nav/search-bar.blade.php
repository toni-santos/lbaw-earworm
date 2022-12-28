<form id="search-form" class="search-form" method="GET" action={{route('catalogue')}}>
    @if (!empty(request('search')))
    <input name="search" type="text" class="searchbar" id="visible-search" value="{{request('search')}}" placeholder="Search">
    @else
    <input name="search" type="text" class="searchbar" id="visible-search" placeholder="Search">
    @endif
    <button type="submit" class="search-icon">
        <span class="material-icons">search</span>
    </button>
</form>
