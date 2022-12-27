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
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined" />
    <link href="{{ asset('css/global.css') }}" rel="stylesheet">
    <link rel="stylesheet" href="https://unpkg.com/flickity@2/dist/flickity.min.css">
    
    @switch($page)
      @case('catalogue')
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/catalogue.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/catalogue.js') }} defer></script>
        @break

      @case('sign')
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/forms.js') }} defer></script>
        @break
      
      @case('user')
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/user.css') }}" rel="stylesheet">
        <script type="module" src={{ asset('js/user.js') }} defer></script>
        @break

      @case('cart')
        <link href="{{ asset('css/cart.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/checkout.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/cart.js') }} defer></script>
        @break

      @case('checkout')
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <link href="{{ asset('css/checkout.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/checkout.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/forms.js') }} defer></script>
      
      @case('product')
        <link href="{{ asset('css/product.css') }}" rel="stylesheet">
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/review.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/product.js') }} defer></script>
        @break

      @case('settings')
        <link href="{{ asset('css/settings.css') }}" rel="stylesheet">   
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <link href="{{ asset('css/admin.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/forms.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/admin.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/usersettings.js') }} defer></script>
        @break

      @case('admin')
        <link href="{{ asset('css/forms.css') }}" rel="stylesheet">
        <link href="{{ asset('css/admin.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/forms.js') }} defer></script>
        <script type="text/javascript" src={{ asset('js/admin.js') }} defer></script>
        @break

      @case('wishlist')
        <link href="{{ asset('css/wishlist.css') }}" rel="stylesheet">
        @break

      @case('artist')
        <link href="{{ asset('css/artist.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <script type="module" src={{ asset('js/BBCode_to_HTML.js') }} defer></script>
        <script type="module" src={{ asset('js/artist.js') }} defer></script>
        @break

      @case('about-us')
        <link href="{{ asset('css/statics.css') }}" rel="stylesheet">
        @break

      @case('orders')
        <link href="{{ asset('css/orders.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/orders.js') }} defer></script>
        @break
      
      @case('help')
        <link href="{{ asset('css/statics.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/statics.js') }} defer></script>
        @break
        
      @default
        <link href="{{ asset('css/carousel.css') }}" rel="stylesheet">
        <link href="{{ asset('css/cards.css') }}" rel="stylesheet">
        <link href="{{ asset('css/index.css') }}" rel="stylesheet">
        <script type="text/javascript" src={{ asset('js/index.js') }} defer></script>
        
      @endswitch
        
    <script type="text/javascript" src={{ asset('js/like.js') }} defer></script>
    <script type="text/javascript" src={{ asset('js/cart.js') }} defer></script>
    <script type="text/javascript">
        // Fix for Firefox autofocus CSS bug
        // See: http://stackoverflow.com/questions/18943276/html-5-autofocus-messes-up-css-loading/18945951#18945951
    </script>
    <script type="text/javascript" src={{ asset('js/global.js') }} defer></script>
    <script src="https://unpkg.com/flickity@2/dist/flickity.pkgd.min.js"></script>

  </head>
  @include('partials.nav.navbar')
  <body>
