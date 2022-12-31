@include('partials.common.head', ['page' => "admin"])

<main id="index-main">
    @include('partials.backoffice.admin-nav')
    <section id="flash-topics">
        @include('partials.backoffice.flash-card', ['items' => $products, 'title' => 'Products'])
        @include('partials.backoffice.flash-card', ['items' => $orders, 'title' => 'Orders'])
        @include('partials.backoffice.flash-card', ['items' => $tickets, 'title' => 'Tickets'])
        @include('partials.backoffice.flash-card', ['items' => $reports, 'title' => 'Reports'])
    </section>
    @include('partials.backoffice.misc-notification')
</main>
@include('partials.common.foot')