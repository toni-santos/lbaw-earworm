@include('partials.common.head', ['page' => "orders", 'title' => ' - Orders'])

<main>
    @if (count($orders) > 0)
        @include('partials.common.subtitle', ['title' => "Orders"])
        @foreach ($orders as $order)
            @include('partials.common.order-card', ['order' => $order, 'products' => $order['products']])
        @endforeach
    @else
    <div id="empty-order-wrapper">
        <h2 id="empty-order-text">You haven't ordered anything yet!</h2>
        <a href="{{route('catalogue')}}"><span id="empty-order-icon" class="material-icons">inventory_2</span></a>
    </div>
    @endif
</main>
@include('partials.common.foot')