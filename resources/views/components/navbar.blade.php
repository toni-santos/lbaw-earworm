<nav id="navbar-wide" class="navbar">
    <div id="wide-top" class="sub-bar">
        <div id="logo-div">
            <a href="{{route('home')}}"> <img id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png"> </a> 
            <a href="{{route('home')}}"> <p id="site-name">EarWorm</p> </a>
        </div>
        <div class="search-container">
            <x-SearchBar />
        </div>
        <div id="icons">
            <!-- account_circle is a placeholder for the users pfp -->
            @if (Auth::check())
            <a href="" id="wishlist-icon"><span class="material-symbols-outlined">favorite</span></a>
            <a href="{{route('checkout')}}" id="cart-icon"><span class="material-symbols-outlined">shopping_basket</span></a>
            <a href="" id="profile-icon"><span class="material-symbols-outlined">account_circle</span></a>
            @include('partials.profiledropdown')
            @include('partials.cartdropdown')
            @include('partials.wishlistdropdown')
            @else
            <a href="{{route('checkout')}}" id="cart-icon"><span class="material-symbols-outlined">shopping_basket</span></a>
            <a href="{{route('login')}}" id="profile-icon" title="Login"><span class="material-symbols-outlined">login</span></a>
            @include('partials.cartdropdown')
            @endif
        </div>
    </div>
    <div id="wide-bot" class="sub-bar">
        <a href="">New Deals</a>
        <a href="">Trending</a>
        <a href="">Indievember</a>
    </div>
</nav>

<nav id="navbar-mobile" class="navbar">
    <div id="logo-div">
        <img id="logo" src="https://img.icons8.com/fluency/512/earth-worm.png">
        <p id="site-name">EarWorm</p>
    </div>
    <div id="hamburger" data-show="false">
        <span id="hamburger-icon" class="material-symbols-outlined">menu</span>
    </div>
</nav>
<div id="mobile-content">
    <div class="search-container">
        <x-SearchBar />
    </div>
    <div id="mobile-content-screen">
        <div id="mobile-nav-promos">
            <a>New Deals</a>
            <a>Trending</a>
            <a>Indievember</a>
        </div>
        <div id="mobile-icons">
            <a><span class="material-symbols-outlined">favorite</span>Wishlist</a>
            <a><span class="material-symbols-outlined">shopping_basket</span>Cart</a>
            <div id="mobile-nav-profile">
                <div id="mobile-nav-profile-icon">
                    <span class="material-symbols-outlined">account_circle</span>
                    <a>User</a>
                </div>
                <a><span class="material-symbols-outlined">logout</span></a>
            </div>
        </div>
    </div>
</div>
<div id="obscure-bg"></div>
