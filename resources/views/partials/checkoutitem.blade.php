
<article class="checkout-item" id="checkout-item-{{$id}}">
    <div class="left-item">
        <img alt="Item picture" class="item-img" src="https://picsum.photos/100/100?random=1">
        <p class="item-name">{{ $details['name'] }} </p>
    </div>
    <div class="right-item">
        <div class="right-item-top">
            <span class="" onclick="decreaseAmountCheckout(event, {{$id}})">-</span>
            <a class="item-amnt">{{ $details['quantity'] }}</a>
            <span class="" onclick="increaseAmountCheckout(event, {{$id}})">+</span>
            <p class="">{{ $details['price'] }}€</p>
        </div>
        <p class="" onclick="removeItemCheckout(event, {{$id}})"><span class="material-symbols-outlined">delete</span></p>
    </div>
</article>