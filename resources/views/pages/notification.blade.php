@include('partials.common.head', ['page' => "notification"])

<main>
    @include('partials.common.subtitle', ['title' => 'Notifications'])
    <div id="notif-wrapper">
    @foreach ($notifications as $notif)
        @include('partials.common.notification-card', ['notif' => $notif])
    @endforeach
    </div>
</main>
@include('partials.common.foot')