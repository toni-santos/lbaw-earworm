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
            <a href="{{ route('decreaseFromCart', [ 'id' => $id ]) }}" class="dec-cart-item">-</a>
            <p>{{$details['quantity']}}</p>
            <a href="{{ route('addToCart', [ 'id' => $id ]) }}" class="inc-cart-item">+</a>
        </div>
        <a><span class="material-symbols-outlined">delete</span></a>
    </div>
</div>