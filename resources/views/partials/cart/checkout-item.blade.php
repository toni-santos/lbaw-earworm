
<article class="checkout-item" id="checkout-item-{{$id}}">
    <div class="left-item">
        <img width="100px" height="100px" alt="Item picture" class="item-img" src={{ url('/images/products/'. $id .'.jpg') }}>
        <p class="item-name">{{ $details['name'] }} </p>
    </div>
    <div class="right-item">
        <div class="right-item-top">
            <a class="item-amnt">{{ $details['quantity'] }}</a>
            <div class="increase-decrease-icons">
                <span class="material-icons" id="minus-icon" onclick="decreaseAmountCheckout(event, {{$id}})">remove</span>
                <span class="material-icons" id="plus-icon" onclick="increaseAmountCheckout(event, {{$id}})">add</span>
            </div>
        </div>
        <p class="" onclick="removeItemCheckout(event, {{$id}})"><span class="material-icons" id="delete-icon">delete</span></p>
    </div>
</article>