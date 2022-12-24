<div>
    @if ($carouselTitle != '')
        @include('partials.common.subtitle', ['title' => $carouselTitle])
    @endif
    
    <div class="carousel-container">
        <div id="{{$carouselId}}">
            @foreach ($content as $product)
                @include('partials.common.product-card', ['product' => $product])
            @endforeach
        </div>
    </div>
</div>
