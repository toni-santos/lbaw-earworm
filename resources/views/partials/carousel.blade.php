<div>
    @if ($carouselTitle != '')
        <x-Subtitle title="{{$carouselTitle}}"/>
    @endif
    <div class="carousel-container">
        <x-Carousel id="{{$carouselId}}" promo="{{$promo}}" />
    </div>
</div>
