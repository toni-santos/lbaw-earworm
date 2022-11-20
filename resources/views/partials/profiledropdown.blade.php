<div class="nav-dropdowns" id="profile-dropdown">
    <!-- TODO format this to blade and make it prettier !-->
    <?php if (Auth::check()) {?>
    <div>
        <h3>{{Auth::user()->username}}</h3>
    </div>
    <?php } ?>
    <div>
        <a href=""><span class="material-symbols-outlined">package</span></a>            
        <a href="">Orders</a>
    </div>
    <div>
        <a href=""><span class="material-symbols-outlined">settings</span></a>            
        <a href="">Settings</a>
    </div>
    <div>
        <?php if (Auth::check()) { ?> 
        <a href=""><span class="material-symbols-outlined">logout</span></a>
        <a href="{{route ('logout')}}">Logout</a>
        <?php } else { ?>
        <a href=""><span class="material-symbols-outlined">login</span></a>
        <a href={{route ('login')}}>Login</a>
        <?php } ?> 
    </div>
</div>