@props([
    'page' => 'index',
])

<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <!-- CSRF Token -->
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>{{ config('app.name', 'Laravel') }}</title>

    <!-- Styles -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@48,400,0,0" />
    <link href="{{ asset('css/global.css') }}" rel="stylesheet">
    {{-- UNCOMMENT THIS WHEN ENABLING FLICKR --}}
    {{-- <link rel="stylesheet" href="https://unpkg.com/flickity@2/dist/flickity.min.css"> --}}
    
    @switch($page)
      @case('catalogue')
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/catalogue.css') }}" rel="stylesheet">
        @break

      @case('sign')
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/forms.js') }} defer></script>
        @break
      
      @case('user')
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/user.css') }}" rel="stylesheet">
        <link href="{{ asset('css/review.css') }}" rel="stylesheet">
        @break

      @case('checkout')
        <link href="{{ asset('css/checkout.css') }}" rel="stylesheet">
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/index.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/checkout.js') }} defer></script>
        @break
      
      @default
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/index.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/index.js') }} defer></script>
        
    @endswitch

    <script type="text/javascript">
        // Fix for Firefox autofocus CSS bug
        // See: http://stackoverflow.com/questions/18943276/html-5-autofocus-messes-up-css-loading/18945951#18945951
    </script>
    <script type="text/javascript" src={{ asset('js/global.js') }} defer></script>
    {{-- UNCOMMENT THIS WHEN ENABLING FLICKR (copium)--}}
    {{-- <script src="https://unpkg.com/flickity@2/dist/flickity.pkgd.min.js"></script> --}}

  </head>
  <x-Navbar/>
  <body>
