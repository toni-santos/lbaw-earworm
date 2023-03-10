<?php use App\Http\Controllers\UploadController; ?>
<nav id="navbar-wide" class="navbar">
    <div id="wide-top" class="sub-bar">
        <div id="logo-div">
            <a href="{{route('home')}}"> <img alt="Logo" id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png"> </a> 
            <a href="{{route('home')}}"> <p id="site-name">EarWorm</p> </a>
        </div>
        <div class="search-container">
            @include('partials.nav.search-bar')
        </div>
        <div id="icons">
            @if (Auth::check())
                @if (!Auth::user()->is_admin)
                <a href="{{route('catalogue')}}" id="catalogue-icon"><span class="material-icons">album</span></a>
                <a href="{{route('wishlist')}}" id="wishlist-icon"><span class="material-icons">favorite</span></a>
                <a href="{{route('cart')}}" id="cart-icon"><span class="material-icons">shopping_basket</span></a>
                <a href="{{route('notification')}}" id="notification-icon"><span class="material-icons">notifications</span></a>
                <a href="{{route('ownprofile')}}" id="profile-icon"><span class="material-icons">account_circle</span></a>
                @include('partials.nav.profile-dropdown')
                @include('partials.nav.cart-dropdown')
                @include('partials.nav.notification-dropdown')
                @else
                <a href="{{route('adminIndex')}}" id="dashboard-icon"><span class="material-icons">dashboard</span></a>
                <a href="{{route('catalogue')}}" id="catalogue-icon"><span class="material-icons">album</span></a>
                <a href="{{route('notification')}}" id="notification-icon"><span class="material-icons">notifications</span></a>
                <a href="{{route('ownprofile')}}" id="profile-icon"><span class="material-icons">account_circle</span></a>
                @include('partials.nav.profile-dropdown')
                @include('partials.nav.notification-dropdown')
                @endif
            @else
            <a href="{{route('catalogue')}}" id="catalogue-icon"><span class="material-icons">album</span></a>
            <a href="{{route('cart')}}" id="cart-icon"><span class="material-icons">shopping_basket</span></a>
            <a href="{{route('login')}}" id="profile-icon" title="Login"><span class="material-icons">login</span></a>
            @include('partials.nav.cart-dropdown')
            @endif
        </div>
    </div>
</nav>

<nav id="navbar-mobile" class="navbar">
    <div>
        <div id="logo-div">
            <a href="{{route('home')}}"><img alt="Logo" id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png"></a>
            <a href="{{route('home')}}"><p id="site-name">EarWorm</p></a>
        </div>
        <div id="hamburger" data-show="false">
            <span id="hamburger-icon" class="material-icons">menu</span>
        </div>
    </div>
    <div class="search-container">
        @include('partials.nav.search-bar')
    </div>
</nav>
<div id="mobile-content">
    <div id="mobile-content-screen">
        <div id="mobile-icons">
            @if (Auth::check())
                @if (!Auth::user()->is_admin)
                <a href="{{route('order')}}"><span class="material-icons">inventory_2</span>Orders</a>
                <a href="{{route('notification')}}" id="notification-icon"><span class="material-icons">notifications</span>Notifications</a>
                <a href="{{route('wishlist')}}"><span class="material-icons">favorite</span>Wishlist</a>
                <a href="{{route('cart')}}"><span class="material-icons">shopping_basket</span>Cart</a>
                <a href="{{route('catalogue')}}"><span class="material-icons">album</span>Catalogue</a>
                @else
                <a href="{{route('notification')}}" id="notification-icon"><span class="material-icons">notifications</span>Notifications</a>
                <a href="{{route('catalogue')}}"><span class="material-icons">album</span>Catalogue</a>
                <a href="{{route('adminIndex')}}"><span class="material-icons">dashboard</span>Dashboard</a>
                @endif
                <div id="mobile-nav-profile">
                    <div id="mobile-nav-profile-icon">
                        <a href="{{route('profile', ['id' => Auth::id()])}}"><img alt="User Image" id="dropdown-pfp" src={{UploadController::getUserProfilePic(Auth::id())}}></a>
                        <a href="{{route('profile', ['id' => Auth::id()])}}">{{Auth::user()->username}}</a>
                    </div>
                    <a href="{{route ('logout')}}"><span class="material-icons">logout</span></a>
                </div>
            @else
            <a href="{{route('cart')}}"><span class="material-icons">shopping_basket</span>Cart</a>
            <a href="{{route('login')}}" id="profile-icon" title="Login"><span class="material-icons">login</span>Login</a>
            @endif
        </div>
    </div>
</div>
<div id="obscure-bg"></div>
