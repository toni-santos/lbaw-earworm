<div class="result-wrapper">
    <div class="result-top-{{$ticket->id}}" onclick="expandOptions(event, {{$ticket->id}})">
        <div class="result-top-content">
            <div class="result-info">
                <p>Ticket ID: {{$ticket->id}}</p>
                <a href="{{route('profile', ['id' => $ticket->ticketer_id])}}">Ticketer ID: {{$ticket->ticketer_id}}</a>
                <p>Description: {{$ticket->message}}</p>
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$ticket->id}}">
        <div>
            <form method="POST" class="form-bot" action="">
                {{ csrf_field() }}
                <div class="input-container">
                    <input class="text-input" type="text" name="stock" onkeyup="updateForm(event)" onfocus="checkFilled(event)" placeholder=" ">
                    <label class="input-label" for="stock">Title</label>
                </div>
                <textarea placeholder="Answer" id="message" class="text-input" name="message" rows="6" cols="100"></textarea>
                <section class="inputs-box">
                    <button class="confirm-button" type="submit">Answer</button>
                </section>
            </form>
        </div>
    </div>
</div>
