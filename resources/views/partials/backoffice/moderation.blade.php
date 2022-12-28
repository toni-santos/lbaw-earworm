<div class="result-wrapper">
    <div class="result-top-{{$order->id}}" onclick="expandOptions(event, {{$order->id}})">
        <div class="result-top-content">
            <div class="result-info">
                
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$order->id}}">
        <div>
            @if ($order->state != "Canceled")
                <form method="POST" class="form-bot" action="{{route('adminUpdateOrder', ['id' => $order->id])}}">
                </form>
                <form method="POST" class="form-bot" action="{{route('adminCancelOrder', ['id' => $order->id])}}">
                    {{ csrf_field() }}
                    <button class="confirm-button" type="submit">Cancel</button>
                </form>
            @else
                <p>This order was canceled!</p>
            @endif
        </div>
    </div>    
</div>
