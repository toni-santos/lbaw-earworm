<?php use App\Http\Controllers\UploadController; ?>

<div class="order">
    <div class="order-top-{{$order->id}}" x-id={{$order->id}} onclick="expand({{$order->id}})">
        <div>
            <p>Order no.: {{$order->id}}</p>
            <p>Status: {{$order->state}}</p>
            <p>Address: {{$order->address}}</p>
            <p>Payment Method: {{$order->payment_method}}</p>
        </div>
        <span id="order-expand-{{$order->id}}" class="material-icons">expand_more</span>
    </div>
    <div class="order-bot-{{$order->id}}">
        @foreach ($products as $product)
        <div class="order-product">
            <img class="order-img" src={{ UploadController::getProductProfilePic($product['id']) }}>
            <div>
                <p>Name: {{$product['name']}}</p>
                <p>Artist: {{$product['artist_name']}}</p>
                <p>Quantity: {{$product['quantity']}}</p>
                <p>Price: {{$product['price']}}</p>
            </div>
        </div>
        @endforeach
    </div>
</div>