<p
@if ($stock > 3)
class="green-stock"
@elseif ($stock > 0)
class="yellow-stock"
@else
class="red-stock"
@endif
><span class="material-icons">shopping_cart</span>
@if ($stock > 3)
Available
@elseif ($stock > 0)
Low Stock
@else
Not Available
@endif</p>
