@props([
    'id',
    'promo',
    'products'
])

<div id={{$id}}>
    @if ($promo == false)
        @foreach ($products as $product)
            <x-ProductCard :product='$product'/>
        @endforeach
    @else
        @for ($i = 0; $i < 1; $i++)
            @include('partials.promocard')
        @endfor
    @endif
</div>