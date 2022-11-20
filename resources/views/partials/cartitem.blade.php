<!-- MISSING AN ID FOR NOW AS THERE IS NO BE --> 

<div class="cart-item">
    <div class="cart-item-desc">
        <a><img src="https://picsum.photos/48/48?random=1" class="cart-img"></a>
        <div class="cart-item-specs">
            <a href="/products/{{$id}}">{{$details['name']}}</a>
            <p>{{$details['price']}}€</p>
        </div>
    </div>
    <div class="cart-item-left">
        <div class="cart-item-amnt">
            <p class="dec-cart-item">-</p>
            <p>{{$details['quantity']}}</p>
            <p class="inc-cart-item">+</p>
        </div>
        <a><span class="material-symbols-outlined">delete</span></a>
    </div>
</div>