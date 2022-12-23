<form id="search-form" class="search-form" method="GET" action={{route('catalogue')}} onsubmit="return validateForm()">
    @if (!empty(request('search')))
    <input name="search" type="text" class="searchbar" value="{{request('search')}}" placeholder="Search">
    @else
    <input name="search" type="text" class="searchbar" placeholder="Search">
    @endif
    <button type="submit" class="search-icon">
        <span class="material-icons">search</span>
    </button>
</form>
