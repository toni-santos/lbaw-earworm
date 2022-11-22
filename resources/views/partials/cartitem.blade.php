
<div class="cart-item-{{$id}}">
    <div class="cart-item-desc-{{$id}}">
        <a><img src="https://picsum.photos/48/48?random=1" class="cart-img"></a>
        <div class="cart-item-specs">
            <a href="/products/{{$id}}">{{$details['name']}}</a>
            <p>{{$details['price']}}€</p>
        </div>
    </div>
    <div class="cart-item-left">
        <div class="cart-item-amnt">
            <span onclick="decreaseAmountCart(event, {{$id}})" class="dec-cart-item">-</span>
            <p>{{$details['quantity']}}</p>
            <span onclick="increaseAmountCart(event, {{$id}})" class="inc-cart-item">+</span>
        </div>
        <span onclick="removeItemCart(event, {{$id}})" class="material-symbols-outlined">delete</span>
    </div>
</div>