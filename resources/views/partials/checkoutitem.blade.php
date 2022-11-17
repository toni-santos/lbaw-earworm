<article class="checkout-item" id="checkout-item-{{$id}}">
    <div class="left-item">
        <img alt="Item picture" class="item-img" src="https://picsum.photos/100/100?random=1">
        <p class="item-name">Ants From Up There</p>
    </div>
    <div class="right-item">
        <div class="right-item-top">
            <span class="" onclick="decreaseAmount(event)">-</span>
            <a class="item-amnt">1</a>
            <span class="" onclick="increaseAmount(event)">+</span>
            <p class="">X€</p>
        </div>
        <p class="" onclick="removeItem(event)">Remove</p>
    </div>
</article>