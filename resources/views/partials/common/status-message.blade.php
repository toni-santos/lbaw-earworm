<div class="message-box-wrapper-{{$id}}"> 
        <div class="message-details">
            @if ($type == 'error')
                <span class="material-icons notification-replacement" onclick="clearMessage(event, {{$id}})"> warning </span>
            @else
                <span class="material-icons notification-replacement" onclick="clearMessage(event, {{$id}})"> info </span>
            @endif
        </div>
        <div class="message-description">
            <span class="material-icons message-clear" onclick="clearMessage(event, {{$id}})"> clear </span>
            <p> {{$message}} </p>
        </div>
    </div>
</div>