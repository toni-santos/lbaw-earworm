<div class="result-wrapper">
    <div class="result-top-{{$report->id}}" onclick="expandOptions(event, {{$report->id}})">
        <div class="result-top-content">
            <div class="result-info">
                <p>Report ID: {{$report->id}}</p>
                <a href="{{route('profile', ['id' => $report->reporter_id])}}">Reporter ID: {{$report->reporter_id}}</a>
                <a href="{{route('profile', ['id' => $report->reported_id])}}">Reported ID: {{$report->reported_id}}</a>
                <p>Message: {{$report->message}}</p>
            </div>
        </div>
        <div class="expand">
            <span class="material-icons">expand_more</span>
        </div>
    </div>
    <div class="result-bot-{{$report->id}}">
        <div>
            <form method="POST" class="form-bot" action="{{route('adminBlockReported')}}">
                {{ csrf_field() }}
                <input name="reported_id" value="{{$report->reported_id}}" hidden> 
                <button class="confirm-button" type="submit">Block Reported</button>
            </form>
            <form method="POST" class="form-bot" action="{{route('adminDeleteReport', ['id' => $report->id])}}">
                {{ csrf_field() }}
                <button class="confirm-button" type="submit">Delete</button>
            </form>

        </div>
    </div>
</div>
