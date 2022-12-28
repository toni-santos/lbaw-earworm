<div id="review-edit-top">
    @if (Auth::id() == $review->reviewer_id)
    @include('partials.common.review', ['type' => "product", 'review' => $review, 'edit' => true]) 
    @else
    @include('partials.common.review', ['type' => "product", 'review' => $review, 'edit' => false]) 
    @endif
</div> 

