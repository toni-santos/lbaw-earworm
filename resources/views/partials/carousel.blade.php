<div>
    @if ($carouselTitle != '')
        <x-Subtitle title="{{$carouselTitle}}"/>
    @endif
    
    <div class="carousel-container">
        <x-Carousel id="{{$carouselId}}" promo="{{$promo}}" :products='$products' />
    </div>     

</div>
