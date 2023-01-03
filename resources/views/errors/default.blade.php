@include('partials.common.head', ['page' => "error",'title' => ' - {{$exception->getStatusCode()}}'])
<main>
    <section class="error-page-wrapper">
        <h1 class="error-header">Something went wrong!</h1>
        <p class="error-subheader">This cat will explain it to you:</p>
        <div class="error-image-container">
            <img class="error-image" src="https://http.cat/{{$exception->getStatusCode()}}">
        </div>
        <a class="confirm-button" href="{{route('home')}}"id="back-to-home">Return to Home page</a>
    </section>
</main>
@include('partials.common.foot')