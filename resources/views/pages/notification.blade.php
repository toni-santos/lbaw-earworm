@include('partials.common.head', ['page' => "notification", 'title' => ' - Notifications'])

<main>
    @if (count($notifications) > 0)
    @include('partials.common.subtitle', ['title' => 'Notifications'])
        <div id="notif-wrapper">
        @foreach ($notifications as $notif)
            @include('partials.common.notification-card', ['notif' => $notif])
        @endforeach
        </div>
    @else
    <div id="empty-notification-wrapper">
        <h2 id="empty-notification-text">There are no new notifications for now</h2>
        <a href="{{route('home')}}"><span id="empty-notification-icon" class="material-icons">notifications</span></a>
    </div>
    @endif
</main>
@include('partials.common.foot')