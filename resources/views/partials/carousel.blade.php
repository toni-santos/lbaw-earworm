<div>
    @if ($carouselTitle != '')
        <x-Subtitle title="{{$carouselTitle}}"/>
    @endif
    
    <div class="carousel-container">
        <div id="{{$carouselId}}">
            @switch($type)
                @case("artist")
                    @foreach ($content as $artist)
                        <x-ArtistCard :artist='$artist'/>
                    @endforeach
                    @break
                @case("product")
                    @foreach ($content as $product)
                        <x-ProductCard :product='$product'/>
                    @endforeach
                    @break
                @case("promo")
                    {{-- SWITCH $i TO 3 WHEN CAROUSEL IMPLEMENTED --}}
                    @for ($i = 0; $i < 1; $i++)
                        @include('partials.promocard')
                    @endfor
                    @break
                @default
                    @break
                    
            @endswitch
        </div>
    </div>
</div>
