<?php
$item = ['id' => 1, 'type' => 'order'];
$item2 = ['id' => 1, 'type' => 'product'];
$item3 = ['id' => 1, 'type' => 'yes'];
?> 
<div class="nav-dropdowns" id="notification-dropdown">
    <p>Notifications</p>
    <div id="notification-wrapper">
        @include('partials.common.notification-item', ['item' => $item2])
        @include('partials.common.notification-item', ['item' => $item])
        @include('partials.common.notification-item', ['item' => $item3])
    </div>
</div>
