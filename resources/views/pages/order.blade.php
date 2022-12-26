@include('partials.common.head', ['page' => "orders"])
<main>
    @include('partials.common.subtitle', ['title' => "Orders"])
    @if (!empty($orders))
    @foreach ($orders as $order)
        @include('partials.common.order-card', ['order' => $order, 'products' => $order['products']])
    @endforeach
    @else
    <h1 id="empty-orders">You currently don't have any orders!</h1>
    @endif
</main>
@include('partials.common.foot')