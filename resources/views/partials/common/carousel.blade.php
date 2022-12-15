<div>
    @if ($carouselTitle != '')
        @include('partials.common.subtitle', ['title' => $carouselTitle])
    @endif
    
    <div class="carousel-container">
        <div id="{{$carouselId}}">
            @switch($type)
                @case("artist")
                    @foreach ($content as $artist)
                        @include('partials.common.artist-card', ['artist' => $artist])
                    @endforeach
                    @break
                @case("product")
                    @foreach ($content as $product)
                        @include('partials.common.product-card', ['product' => $product])
                    @endforeach
                    @break
                @case("promo")
                    @for ($i = 0; $i < 3; $i++)
                        @include('partials.common.promocard')
                    @endfor
                    @break
                @default
                    @break
                    
            @endswitch
        </div>
    </div>
</div>
