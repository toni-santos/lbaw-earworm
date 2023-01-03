<?php use App\Http\Controllers\UploadController; ?>
<div class="buy-history-card">
    <img alt="Product Image" class="buy-history-img" src="{{UploadController::getProductProfilePic($product['id'])}}">
    <div class="buy-history-desc">
        <div>
            <p>{{$product['name']}}</p>
            <p>{{$product['artist_name']}}</p>
            <p>{{$product['format']}}</p>
        </div>
        <p>{{$product['price']}}</p>
    </div>
</div>