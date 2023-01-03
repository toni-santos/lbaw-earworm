<?php use App\Http\Controllers\UploadController; ?>
<section class="wishlist-display-item"> 
    <a href="{{ route('product', ['id' => $product['id']]) }}" > <img alt="Product Image" class="wishlist-display-img" src={{ UploadController::getProductProfilePic($product['id']) }}> </a>
    <a class="wishlist-display-name" href="{{ route('product', ['id' => $product['id']]) }}"> {{ $product['name'] }} </a>
</section>