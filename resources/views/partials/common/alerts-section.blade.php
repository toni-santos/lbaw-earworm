<?php $id = 0; ?>
@foreach ($errors->all() as $error)
    @include('partials.common.status-message', ['message' => $error, 'id' =>  $id, 'type' => 'error'])   
    <?php $id++; ?>
@endforeach
@if (\Session::has('message'))
    @include('partials.common.status-message', ['message' => \Session::get('message'), 'id' =>  $id, 'type' => 'message'])   
@endif