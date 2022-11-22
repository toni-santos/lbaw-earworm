<x-Head page="admin"/>
<main >
    <x-Subtitle title="User Administration"/>
    <div id="user-admin-top">
        <form id="user-sb" method="GET" action="{{route('adminpage') }}">
            <input name="user" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-symbols-outlined">search</span>
            </button>        
        </form>
        <p id="create-user-button">Create User</p>
    </div>
    <div id="user-list">
        @foreach ($users as $user)
            @include('partials.adminuser', ['user' => $user])
        @endforeach
    </div>
</main>
<x-Foot/>