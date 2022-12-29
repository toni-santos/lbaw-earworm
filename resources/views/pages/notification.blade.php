<?php
$item = ['id' => 1, 'type' => 'order'];
$item2 = ['id' => 1, 'type' => 'product'];
$item3 = ['id' => 1, 'type' => 'yes'];
?>
@include('partials.common.head', ['page' => "notification"])
<main>
    @include('partials.common.subtitle', ['title' => 'Notifications'])
    <div id="notif-wrapper">
        @include('partials.common.notification-card', ['item' => $item2])
        @include('partials.common.notification-card', ['item' => $item])
        @include('partials.common.notification-card', ['item' => $item3])
        @include('partials.common.notification-card', ['item' => $item3])
        @include('partials.common.notification-card', ['item' => $item3])
        @include('partials.common.notification-card', ['item' => $item3])
        @include('partials.common.notification-card', ['item' => $item3])
        @include('partials.common.notification-card', ['item' => $item3])
    </div>
    {{-- @foreach ($notification as $notification)
    @endforeach --}}
</main>
@include('partials.common.foot')