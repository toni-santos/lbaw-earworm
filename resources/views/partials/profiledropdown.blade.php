<div class="nav-dropdowns" id="profile-dropdown">
    <!-- TODO format this to blade and make it prettier !-->
    @if (Auth::check())
    <div>
        <a href="{{route('profile', ['id' => Auth::id()])}}"><img src="https://picsum.photos/48/48?random=1"></a>
        <a href="{{route('profile', ['id' => Auth::id()])}}">{{Auth::user()->username}}</a>
    </div>
    <div>
        <a href=""><span class="material-symbols-outlined">package</span></a>            
        <a href="">Orders</a>
    </div>
    <div>
        <a href="{{route('editprofile', ['id' => Auth::id()])}}"><span class="material-symbols-outlined">settings</span></a>            
        <a href="{{route('editprofile', ['id' => Auth::id()])}}">Settings</a>
    </div>
    @endif
    <div>
        @if (Auth::check())
        <a href=""><span class="material-symbols-outlined">logout</span></a>
        <a href="{{route ('logout')}}">Logout</a>
        @else
        <a href=""><span class="material-symbols-outlined">login</span></a>
        <a href="{{route ('login')}}">Login</a>
        @endif
    </div>
</div>