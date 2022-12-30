<div id="misc-notif-form-wrapper">
    <form method="POST" class="form-bot" action="{{route('adminNotify')}}">
        {{ csrf_field() }}
        <input type="text" placeholder="Alert Users..." id="message" class="text-input" name="message" ></textarea>

        <button class="confirm-button" type="submit">Broadcast Notification</button>
    </form>
</div>