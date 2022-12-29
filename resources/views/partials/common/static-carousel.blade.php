<div>
    @if ($carouselTitle != '')
        @include('partials.common.subtitle', ['title' => $carouselTitle])
    @endif
    
    <div class="carousel-container">
        <div id="{{$carouselId}}">
            @switch($type)
                @case('product')
                    @foreach ($content as $product)
                        @include('partials.common.product-card', ['product' => $product, 'wishlist' => $wishlist])
                    @endforeach
                    
                    @break
                @case('artist')
                    @foreach ($content as $product)
                        @include('partials.common.artist-card', ['artist' => $artist])
                    @endforeach

                    @break
                @default
                    
            @endswitch
        </div>
    </div>
</div>
