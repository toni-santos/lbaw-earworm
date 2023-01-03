<?php use App\Http\Controllers\UploadController; ?>
<div class="cart-item-{{$id}}">
    <a href="{{ route('product', ['id' => $id]) }}"><img alt="Product Image" width="60px" height="60px" src={{ UploadController::getProductProfilePic($id) }} class="cart-img"></a>
    <div class="cart-desc-{{$id}}">
        <a href="/product/{{$id}}">{{$details['name']}}</a>
        <p>{{$details['discounted_price']}}€</p>
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