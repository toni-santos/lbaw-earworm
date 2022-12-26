@include('partials.common.head', ['page' => "admin"])
<main id="index-main">
    @include('partials.backoffice.admin-nav')
    <section id="flash-topics">
        @include('partials.backoffice.flash-card', ['items' => $products, 'title' => 'Products'])
        {{-- @include('partials.backoffice.flash-card', $orders) --}}
    </section>
</main>
@include('partials.common.foot')