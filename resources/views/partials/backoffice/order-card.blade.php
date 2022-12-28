<div class="result-wrapper">
    <div class="result-top-{{$order->id}}" onclick="expandOptions(event, {{$order->id}})">
        <div class="result-top-content">
            <div class="result-info">
                <p>ID: {{$order->id}}</p>
                <p>Status: {{$order->state}}</p>
                <p>Products:<br></p>
                @foreach ($order['products'] as $product)
                <p>&emsp;{{$product['name']}} ({{$product['id']}}) - {{$product['quantity']}}</p>
                @endforeach
                </p>
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$order->id}}">
        <div>
            @if ($order->state != "Canceled")
                <form method="POST" class="form-bot" action="{{route('adminUpdateOrder', ['id' => $order->id])}}">
                    {{ csrf_field() }}
                    <select name="state" id="state" class="select-filter">
                        <option value="Processing">Processing</option>
                        <option value="Shipped">Shipped</option>
                        <option value="Delivered">Delivered</option>
                    </select>
                    <section class="inputs-box">
                        <button class="confirm-button" type="submit">Change</button>
                    </section>
                </form>
                <form method="POST" class="form-bot" action="{{route('adminCancelOrder', ['id' => $order->id])}}">
                    {{ csrf_field() }}
                    <button class="confirm-button" type="submit">Cancel</button>
                </form>
            @else
                <p>This order was canceled!</p>
            @endif
        </div>
    </div>    
</div>
