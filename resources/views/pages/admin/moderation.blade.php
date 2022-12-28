@include('partials.common.head', ['page' => "admin"])
<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Report & Ticket Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminMod') }}">
            <input name="artist" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
            <select name="mod-filter" id="mod-filter">
                <option value="All">All</option>
                <option value="Ticket">Ticket</option>
                <option value="Report">Report</option>
            </select>
        </form>
    </div>
    <div id="result-list">
        {{-- @foreach ($tickets as $ticket)
        @include('partials.backoffice.ticket', ['ticket' => $ticket])
        @endforeach --}}
        @foreach ($reports as $report)
        @include('partials.backoffice.report', ['report' => $report])
        @endforeach
    </div>
</main>
@include('partials.common.foot')