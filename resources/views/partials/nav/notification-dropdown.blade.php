@php
    $notifications = Auth::user()->notifications;
@endphp
<div class="nav-dropdowns" id="notification-dropdown">
    <p>Notifications</p>
    <div id="notification-wrapper">
    @foreach ($notifications as $notif)
        @include('partials.common.notification-item', ['notif' => $notif])
    @endforeach
    </div>
</div>
