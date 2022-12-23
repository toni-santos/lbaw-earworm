<nav id="navbar-wide" class="navbar">
    <div id="wide-top" class="sub-bar">
        <div id="logo-div">
            <a href="{{route('home')}}"> <img id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png"> </a> 
            <a href="{{route('home')}}"> <p id="site-name">EarWorm</p> </a>
        </div>
        <div class="search-container">
            @include('partials.nav.search-bar')
        </div>
        <div id="icons">
            <!-- account_circle is a placeholder for the users pfp -->
            @if (Auth::check())
            <a href="{{route('catalogue')}}" id="catalogue-icon"><span class="material-icons">album</span></a>
            <a href="" id="wishlist-icon"><span class="material-icons">favorite</span></a>
            <a href="{{route('checkout')}}" id="cart-icon"><span class="material-icons">shopping_basket</span></a>
            <a href="{{route('ownprofile')}}" id="profile-icon"><span class="material-icons">account_circle</span></a>
            @include('partials.nav.profile-dropdown')
            @include('partials.nav.cart-dropdown')
            @include('partials.nav.wishlist-dropdown')
            @else
            <a href="{{route('catalogue')}}" id="catalogue-icon"><span class="material-icons">album</span></a>
            <a href="{{route('checkout')}}" id="cart-icon"><span class="material-icons">shopping_basket</span></a>
            <a href="{{route('login')}}" id="profile-icon" title="Login"><span class="material-icons">login</span></a>
            @include('partials.nav.cart-dropdown')
            @endif
        </div>
    </div>
</nav>

<nav id="navbar-mobile" class="navbar">
    <div id="logo-div">
        <a href="{{route('home')}}"><img id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png"></a>
        <a href="{{route('home')}}"><p id="site-name">EarWorm</p></a>
    </div>
    <div id="hamburger" data-show="false">
        <span id="hamburger-icon" class="material-icons">menu</span>
    </div>
</nav>
<div id="mobile-content">
    <div class="search-container">
        @include('partials.nav.search-bar')
    </div>
    <div id="mobile-content-screen">
        <div id="mobile-icons">
            @if (Auth::check())
            <a><span class="material-icons">favorite</span>Wishlist</a>
            <a href="{{route('checkout')}}"><span class="material-icons">shopping_basket</span>Cart</a>
            <div id="mobile-nav-profile">
                <div id="mobile-nav-profile-icon">
                    <span class="material-icons">account_circle</span>
                    <a>User</a>
                </div>
                <a><span class="material-icons">logout</span></a>
            </div>
            @else
            <a href="{{route('checkout')}}"><span class="material-icons">shopping_basket</span>Cart</a>
            <a href="{{route('login')}}" id="profile-icon" title="Login"><span class="material-icons">login</span>Login</a>
            @endif
        </div>
    </div>
</div>
<div id="obscure-bg"></div>
