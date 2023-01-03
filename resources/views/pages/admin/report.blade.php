@include('partials.common.head', ['page' => "admin", 'title' => ' - Report Administration'])

<main>
    @include('partials.backoffice.admin-nav')
    @include('partials.common.subtitle', ['title' => "Report Administration"])
    <div id="admin-form-wrapper">
        <form id="sb" method="GET" action="{{ route('adminReport') }}">
            <input name="report" type="text" class="searchbar" placeholder="Search">
            <button type="submit" class="search-icon">
                <span class="material-icons">search</span>
            </button>        
        </form>
    </div>
    <div id="result-list">
        @foreach ($reports as $report)
        @include('partials.backoffice.report', ['report' => $report])
        @endforeach
        {{ $reports->links('vendor.pagination.default') }}
    </div>
</main>
@include('partials.common.foot')