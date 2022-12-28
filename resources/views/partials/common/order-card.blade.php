<div class="order">
    <div class="order-top-{{$order->id}}" x-id={{$order->id}} onclick="expand({{$order->id}})">
        <div>
            <p>Order no.: {{$order->id}}</p>
            <p>Status: {{$order->state}}</p>
        </div>
        <span id="order-expand-{{$order->id}}" class="material-icons">expand_more</span>
    </div>
    <div class="order-bot-{{$order->id}}">
        @foreach ($products as $product)
        <div class="order-product">
            <img class="order-img" src={{ url('/images/products/' . $product['id'] . '.jpg') }}>
            <div>
                <p>Name: {{$product['name']}}</p>
                <p>Artist: {{$product['artist_name']}}</p>
                <p>Quantity: {{$product['quantity']}}</p>
            </div>
        </div>
        @endforeach
    </div>
</div>