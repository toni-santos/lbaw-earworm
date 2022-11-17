@props([
    'id',
    'promo'
])


<div id={{$id}}>
    @if ($promo == false)
        @for ($i = 0; $i < 9; $i++)
            <x-ProductCard />
        @endfor
    @else
        @for ($i = 0; $i < 3; $i++)
            @include('partials.promocard')
        @endfor
    @endif
</div>