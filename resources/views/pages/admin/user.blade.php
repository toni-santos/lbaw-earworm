@include('partials.common.head', ['page' => "admin"])
<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "User Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminUser') }}">
            <input name="user" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
        <a href="{{route('adminCreatePage')}}" id="create-button">Create User</a>
    </div>
    <div id="result-list">
        @foreach ($users as $user)
            @include('partials.backoffice.user-card', ['user' => $user])
        @endforeach
    </div>
</main>
@include('partials.common.foot')