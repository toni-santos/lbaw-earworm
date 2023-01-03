@include('partials.common.head', ['page' => "admin", 'title' => ' - Ticket Administration'])

<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Ticket Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminTicket') }}">
            <input name="ticket" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
    </div>
    <div id="result-list">
        @foreach ($tickets as $ticket)
        @include('partials.backoffice.ticket', ['ticket' => $ticket])
        @endforeach
        {{ $tickets->links('vendor.pagination.default') }}
    </div>
</main>
@include('partials.common.foot')