@include('partials.common.head', ['page' => "admin"])
<main >
    @include('partials.common.subtitle', ['title' => "User Administration"])
    <div id="user-admin-top">
        <form id="user-sb" method="GET" action="{{route('adminpage') }}">
            <input name="user" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
        <a href="{{route('adminCreatePage')}}" id="create-user-button">Create User</a>
    </div>
    <div id="user-list">
        @foreach ($users as $user)
            @include('partials.backoffice.user-card', ['user' => $user])
        @endforeach
    </div>
</main>
@include('partials.common.foot')