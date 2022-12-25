<form method="POST" action="{{route('addReview', ['id' => $product->id])}}" id="review-form">
    {{ csrf_field() }}
    {{-- TODO: USER IMAGE HERE --}}
    <div class="textarea-container">
        <textarea placeholder=" " id="message" class="text-input" name="message" rows="3" cols="100"></textarea>
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
        <button class="review-button" type="submit" value="Submit">Review</button>
    </div>
</form>