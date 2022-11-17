<article class="checkout-item" id="checkout-item-{{$id}}>
    <div class="left-item">
        <img alt="Item picture" class="item-img" src="">
        <section class="item-info">
            <p class="subtitle1">Ants From Up There</p>
        </section>
    </div>
    <div class="right-item">
        <div class="right-item-top">
            <input type="hidden" class="cartItemDishID" name="cartItemDishID" value="{{$id}}">
            <span class="" onclick="decreaseAmount(event, {{$id}})">+</span>
            <a class="">1</a>
            <span class="" onclick="increaseAmount(event, {{$id}})">-</span>
            <p class="">X€</p>
        </div>
        <input type="hidden" class="cartItemDishID" name="cartItemDishID" value="{{$id}}">
        <p class="subtitle2 pointer" onclick="removeItem(event, {{$id}})">Remove</p>
    </div>
</article>