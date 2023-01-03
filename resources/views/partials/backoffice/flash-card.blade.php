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
                <form action="{{route('adminOrder')}}" method="GET" class="flash-item">
                    <button type="submit" class="invis-button">
                        <input type="hidden" name="order" value="{{$item['id']}}">
                        <div>
                            <p>Order No.: {{$item['id']}}</p>
                            <p>User ID: {{$item['user_id']}}</p>
                        </div>
                        <p>State: {{$item['state']}}</p>
                    </button>
                </form>
                @break
            @case('Tickets')
                <form action="{{route('adminTicket')}}" method="GET" class="flash-item">
                    <button type="submit" class="invis-button">
                        <input type="hidden" name="ticket" value="{{$item['id']}}">
                        <div>
                            <p>Ticket ID: {{$item['id']}}</p>
                            <p>Ticketer ID: {{$item['ticketer_id']}}</p>
                            <p title="{{$item['message']}}" class="flash-message">Message: {{$item['message']}}</p>
                        </div>
                    </button>
                </form>
                @break
            @case('Reports')
                <form action="{{route('adminReport')}}" method="GET" class="flash-item">
                    <button type="submit" class="invis-button">
                        <input type="hidden" name="report" value="{{$item['id']}}">
                        <div>
                            <p>Report ID: {{$item['id']}}</p>
                            <p>Reporter ID: {{$item['reporter_id']}}</p>
                            <p>Reported ID: {{$item['reported_id']}}</p>
                        </div>
                    </button>
                </form>
                @break
            @default
                
        @endswitch
    @endforeach            
</section>