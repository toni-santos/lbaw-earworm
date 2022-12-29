<section class="buy-history-item"> 
    <a href="{{ route('product', ['id' => $product['id']]) }}" > <img class="buy-history-img" src={{ url('/storage/images/products/'.$product['id'].'.jpg') }}> </a>
    <a class="buy-history-name" href="{{ route('product', ['id' => $product['id']]) }}"> {{ $product['name'] }}" </a>
</section>