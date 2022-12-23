
<div class="cart-item-{{$id}}">
    <a href="{{ route('product', ['id' => $id]) }}"><img width="60px" height="60px" src={{ url('/images/products/'. $id .'.jpg') }} class="cart-img"></a>
    <div class="cart-desc-{{$id}}">
        <a href="/product/{{$id}}">{{$details['name']}}</a>
        <p>{{$details['price']}}€</p>
        <div class="cart-item-amnt">
            <span onclick="decreaseAmountCart(event, {{$id}})" class="dec-cart-item">-</span>
            <p>{{$details['quantity']}}</p>
            <span onclick="increaseAmountCart(event, {{$id}})" class="inc-cart-item">+</span>
        </div>
    </div>
    <div class="cart-remove">
        <span onclick="removeItemCart(event, {{$id}})" class="material-icons">delete</span>
    </div>
</div>