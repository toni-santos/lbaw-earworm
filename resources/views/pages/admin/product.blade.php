@include('partials.common.head', ['page' => "admin"])
<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Product Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminProduct') }}">
            <input name="product" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
        <a href="{{route('adminCreateProduct')}}" id="create-button">Add Product</a>
    </div>
    <div id="result-list">
        @foreach ($products as $product)
            @include('partials.backoffice.product-card', ['product' => $product])
        @endforeach
    </div>
</main>
@include('partials.common.foot')