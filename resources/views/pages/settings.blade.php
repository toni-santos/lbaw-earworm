@if (!Auth::check())
    {{ redirect(route('/')) }}
@endif
@include('partials.common.head', ['page' => "settings", 'title' => ' - Settings'])
<main id="main-wrapper">
    @include('partials.common.subtitle', ['title' => "Settings"])
    @include('partials.user.settings', ['id' => Auth::user()->id])
</main>
@include('partials.common.foot')