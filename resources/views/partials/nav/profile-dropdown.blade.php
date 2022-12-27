<div class="nav-dropdowns" id="profile-dropdown">
    <!-- TODO format this to blade and make it prettier !-->
    @if (Auth::check())
    <div>
        <a href="{{route('profile', ['id' => Auth::id()])}}"><img src="https://picsum.photos/48/48?random=1"></a>
        <a href="{{route('profile', ['id' => Auth::id()])}}">{{Auth::user()->username}}</a>
    </div>
    <div>
        <a href="{{route('order')}}"><span class="material-icons">inventory_2</span></a>            
        <a href="{{route('order')}}">Orders</a>
    </div>
    <div>
        <a href="{{route('editprofile', ['id' => Auth::id()])}}"><span class="material-icons">settings</span></a>            
        <a href="{{route('editprofile', ['id' => Auth::id()])}}">Settings</a>
    </div>
    @endif
    <div>
        @if (Auth::check())
        <a href="{{route ('logout')}}"><span class="material-icons">logout</span></a>
        <a href="{{route ('logout')}}">Logout</a>
        @else
        <a href="{{route ('login')}}"><span class="material-icons">login</span></a>
        <a href="{{route ('login')}}">Login</a>
        @endif
    </div>
</div>