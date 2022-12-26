<section class="flash-card">
    <p>{{$title}}</p>
    @foreach ($items as $item)
        @switch($title)
            @case('Products')
                <form action="{{route('adminProduct')}}" method="GET" class="flash-item">
                    <button type="submit" class="invis-button">
                        <input type="hidden" name="product" value="{{$item['id']}}">
                        <div>
                            <p>Name: {{$item['name']}}</p>
                            <p>ID: {{$item['id']}}</p>
                        </div>
                        <p>Stock: {{$item['stock']}}</p>
                    </button>
                </form>
                @break
            @case('Orders')
                
                @break
            @default
                
        @endswitch
    @endforeach            
</section>