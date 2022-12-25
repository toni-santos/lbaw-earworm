<div id="review-edit-top">
    @include('partials.common.review', ['type' => "product", 'review' => $review]) 
    <div id="review-edit-options">
        <button class="confirm-button" id="edit-option" onclick="toggleEditReview(event)"> <span class="material-symbols-outlined">edit</span> </button>
        <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
            {{ csrf_field() }}
            <button class="confirm-button" id="delete-option"> <span class="material-symbols-outlined">delete</span> </button>
        </form>
    </div>
</div> 

<div id="review-edit-bot" style="display:none;">   
    <form method="POST" action="{{route('editReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}" id="review-form">
        {{ csrf_field() }}
        <div class="textarea-container">
            <textarea placeholder="{{$review->message}}" id="message" class="text-input" name="message" rows="3" cols="100"></textarea>
            <label class="input-label" for="message">Review</label>
        </div>
        <div id="stars-button-container">
            <div class="star-container">
                <?php for ($i = 0; $i < 5; $i++) { ?>
                    <input class="star input-star" type="radio" name="rating-star" id="star-<?= $i ?>" value="<?= $i+1 ?>" required>
                        <label id="star-label-<?= $i ?>" onclick="selectStar(event)">
                            <span class="material-icons">
                                star_outline
                            </span>
                        </label>
                <?php } ?>
            </div>
            <button class="review-button" type="submit" value="Submit">Update Review</button>
        </div>
    </form>
</div>
