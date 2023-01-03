<?php $notifications = Auth::user()->notifications->reverse(); ?>
<div class="nav-dropdowns" id="notification-dropdown">
    <p>Notifications</p>
    <div id="notification-wrapper">
    @if (count($notifications) > 0)
    @foreach ($notifications as $notif)
        @include('partials.common.notification-item', ['notif' => $notif])
    @endforeach
    @else
    <p class="dropdown-warning">No new notifications</p>
    @endif
    </div>
</div>
