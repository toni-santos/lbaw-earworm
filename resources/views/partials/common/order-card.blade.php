<?php use App\Http\Controllers\UploadController; ?>

<div class="order">
    <div class="order-top-{{$order->id}}" x-id={{$order->id}} onclick="expand({{$order->id}})">
        <div>
            <p>Order no.: {{$order->id}}</p>
            <p>Status: {{$order->state}}</p>
            <p>Address: {{$order->address}}</p>
            <p>Payment Method: {{$order->payment_method}}</p>
        </div>
        @if ($order->state == 'Processing')
        <div>
            <form method="POST" action="{{route('userCancelOrder', ['id' => $order->id])}}">
                {{ csrf_field() }}
                <button type="submit" class="invis-button">Cancel Order</button>
            </form>
            <span id="order-expand-{{$order->id}}" class="material-icons">expand_more</span>
        </div>
        @else
        <div>
            <span id="order-expand-{{$order->id}}" class="material-icons">expand_more</span>
        </div>
        @endif
    </div>
    <div class="order-bot-{{$order->id}}">
        @foreach ($products as $product)
        <div class="order-product">
            <img alt="Product Image" class="order-img" src={{ UploadController::getProductProfilePic($product['id']) }}>
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