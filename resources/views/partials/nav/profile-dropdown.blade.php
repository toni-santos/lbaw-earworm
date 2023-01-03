<?php use App\Http\Controllers\UploadController; ?>
<div class="nav-dropdowns" id="profile-dropdown">
    @if (Auth::check())
    <div>
        <a href="{{route('profile', ['id' => Auth::id()])}}"><img id="dropdown-pfp" src={{UploadController::getUserProfilePic(Auth::id())}}></a>
        <a href="{{route('profile', ['id' => Auth::id()])}}">{{Auth::user()->username}}</a>
    </div>
    @if (!Auth::user()->is_admin)
    <div>
        <a href="{{route('order')}}"><span class="material-icons">inventory_2</span></a>            
        <a href="{{route('order')}}">Orders</a>
    </div>
    @endif
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