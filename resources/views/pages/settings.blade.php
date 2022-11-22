@if (!Auth::check())
    {{ redirect(route('/')) }}
@endif
<x-Head page="settings"/>
<main id="main-wrapper">
    <x-Subtitle title="Settings"/>
    @include('partials.usersettings', ['id' => Auth::user()->id])
</main>
<x-Foot/>