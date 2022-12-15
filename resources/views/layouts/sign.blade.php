@include('partials.common.head', ['page' => "sign"])
<main id="content-wrapper">
    <div id="side-image"></div>
    <section id="sign-wrapper">
        @section('content')
        @show
    </section>
</main>
@include('partials.common.foot')