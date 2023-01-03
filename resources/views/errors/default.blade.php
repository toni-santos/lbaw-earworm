@include('partials.common.head', ['page' => "error",'title' => ' - ' . $exception->getStatusCode()])
<main>
    <section class="error-page-wrapper">
        <h1 class="error-header">{{$exception->getStatusCode()}}</h1>
        <p class="error-subheader">{{$exception->getMessage()}}</p>
        <div class="error-image-container">
            <img class="error-image" src="storage/images/unplugged.png">
        </div>
        <a class="confirm-button" href="{{route('home')}}"id="back-to-home">Return to Home page</a>
    </section>
</main>
@include('partials.common.foot')