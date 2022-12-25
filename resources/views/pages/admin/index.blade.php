@include('partials.common.head', ['page' => "admin"])
<main id="admin-board">
    <a href="{{route('adminUser')}}" id="users-topic" class="admin-topic" style="background-image: url('https://images.unsplash.com/photo-1549732565-d673b928da7f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1169&q=80')"><div class="admin-topic-darken"></div>Users</a>
    <a href="{{route('adminProduct')}}" id="products-topic" class="admin-topic" style="background-image: url('https://images.unsplash.com/photo-1542208998-f6dbbb27a72f?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80')"><div class="admin-topic-darken"></div>Products</a>
    <a href="{{route('adminArtist')}}" id="artists-topic" class="admin-topic" style="background-image: url('https://images.unsplash.com/photo-1493247035880-efdf55d1cc99?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80')"><div class="admin-topic-darken"></div>Artists</a>
    <a href="{{route('adminOrder')}}" id="orders-topic" class="admin-topic" style="background-image: url('https://images.unsplash.com/photo-1587293852726-70cdb56c2866?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Ym94ZXN8ZW58MHx8MHx8&auto=format&fit=crop&w=500&q=60')"><div class="admin-topic-darken"></div>Orders</a>
</main>
@include('partials.common.foot')