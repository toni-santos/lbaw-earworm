@switch($type)
    @case("profile")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <img alt="Product picture" src={{ url('/images/products/' . $review['product_id'] . '.jpg') }} class="reviewer-pfp"> </a>
                    <div>
                        <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <p class="reviewer-name">{{$review['product']['name']}}</p> </a>
                        -
                        <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                        <p class="reviewer-date"> {{$review['date']}} </p>
                    </div>
                </div>
                @if ($edit)
                <div id="review-edit-options">
                    <a class="confirm-button" id="edit-option" href="{{route('product', ['id' => $review['product_id']])}}" > <span class="material-icons">edit</span> </a>
                    <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
                        {{ csrf_field() }}
                        <button class="confirm-button" id="delete-option"> <span class="material-icons">delete</span> </button>
                    </form>
                </div>            
                @endif
            </div>
            @if ($edit)
            <article class="review-message" id="review-message-{{$review['reviewer_id']}}">
                {{$review['message']}}
            </article>
            <div id="review-edit-bot">   
                <form method="POST" action="{{route('editReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}" id="review-form">
                    {{ csrf_field() }}
                    <div class="textarea-container">
                        <textarea placeholder="" id="message" class="text-input" name="message" rows="3" cols="100">
                            {{$review['message']}}
                        </textarea>
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
            @else
            <article class="review-message">
                {{$review['message']}}
            </article>
            @endif
        </section>
        @break
    @case("product")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <img alt="User profile picture" src={{ url('/images/users/' . $review['reviewer_id'] . '.jpg') }} class="reviewer-pfp">
                    <div>
                        <p class="reviewer-name">{{$review['reviewer']['username']}}</p>
                        -
                        <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                        <p class="reviewer-date"> {{$review['date']}} </p>
                    </div>
                </div>
                @if ($edit)
                <div id="review-edit-options">
                    <button class="confirm-button" id="edit-option" onclick="toggleEditReview(event, {{$review['reviewer_id']}})"> <span class="material-icons">edit</span> </button>
                    <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
                        {{ csrf_field() }}
                        <button class="confirm-button" id="delete-option"> <span class="material-icons">delete</span> </button>
                    </form>
                </div>            
                @endif
            </div>
            @if ($edit)
            <article class="review-message" id="review-message-{{$review['reviewer_id']}}">
                {{$review['message']}}
            </article>
            <div id="review-edit-bot">   
                <form method="POST" action="{{route('editReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}" id="review-form">
                    {{ csrf_field() }}
                    <div class="textarea-container">
                        <textarea placeholder="" id="message" class="text-input" name="message" rows="3" cols="100">
                            {{$review['message']}}
                        </textarea>
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
            @else
            <article class="review-message">
                {{$review['message']}}
            </article>
            @endif
        </section>
        @break
    @default
        @break
@endswitch

