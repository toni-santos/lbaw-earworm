<div id="misc-notif-form-wrapper">
    <form method="POST" class="form-bot" action="{{route('adminNotify')}}">
        {{ csrf_field() }}
        <div class="input-container">
            <input type="text" placeholder=" " id="message" class="text-input" name="message" >
            <label class="input-label" for="message" onclick="setFocus(event)">Alert Users</label>
        </div>
        <button class="confirm-button" type="submit">Broadcast Notification</button>
    </form>
</div>