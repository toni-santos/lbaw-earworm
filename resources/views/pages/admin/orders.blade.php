@include('partials.common.head', ['page' => "admin"])
<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Order Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminOrder') }}">
            <input name="order" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
        <a href="{{route('adminCreatePage')}}" id="create-button">Create Order</a>
    </div>
    <div id="result-list">
        @foreach ($orders as $order)
            @include('partials.backoffice.order-card', ['order' => $order])
        @endforeach
        {{ $orders->links('vendor.pagination.default') }}
    </div>
</main>
@include('partials.common.foot')