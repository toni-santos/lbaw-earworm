<?php use App\Http\Controllers\UploadController; ?>
@switch($type)
    @case("profile")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <img alt="Product picture" src={{ UploadController::getProductProfilePic($review['product_id']) }} class="reviewer-pfp"> </a>
                    <div>
                        <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <p class="reviewer-name">{{$review['product']['name']}}</p> </a>
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
                @else   
                <div id="review-edit-options">
                    <form method="POST" id="report-form-container" action="{{route('submitReport')}}"> 
                        {{ csrf_field() }}
                        <input name="user_id" value="{{$review['reviewer_id']}}" hidden>
                        <button class="confirm-button" id="report-option"> <span class="material-icons">flag</span> </button>
                    </form>
                    @if (Auth::check() && Auth::user()->is_admin)
                        <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
                            {{ csrf_field() }}
                            <button class="confirm-button" id="delete-option"> <span class="material-icons">delete</span> </button>
                        </form>
                    @endif
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
                    @if ($review['reviewer']->is_blocked)
                        <img alt="User profile picture" src={{ UploadController::getUserProfilePic('-1') }} class="reviewer-pfp">
                        <div>
                            <p class="reviewer-name">Blocked</p>
                            <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                            <p class="reviewer-date"> {{$review['date']}} </p>
                        </div>
                    @elseif ($review['reviewer']->is_deleted)
                        <img alt="User profile picture" src={{ UploadController::getUserProfilePic('-1') }} class="reviewer-pfp">
                        <div>
                            <p class="reviewer-name">Deleted</p>
                            <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                            <p class="reviewer-date"> {{$review['date']}} </p>
                        </div>
                    @else
                        <a href={{route('profile', ['id' => $review['reviewer']->id])}}>
                            <img alt="User profile picture" src={{ UploadController::getUserProfilePic($review['reviewer_id']) }} class="reviewer-pfp">
                        </a>
                        <div>
                            <a href={{route('profile', ['id' => $review['reviewer']->id])}} class="reviewer-name">{{$review['reviewer']['username']}}</a>
                            <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                            <p class="reviewer-date"> {{$review['date']}} </p>
                        </div>
                    @endif
                </div>
                @if ($edit)
                <div id="review-edit-options">
                    <button class="confirm-button" id="edit-option" onclick="toggleEditReview(event, {{$review['reviewer_id']}})"> <span class="material-icons">edit</span> </button>
                    <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
                        {{ csrf_field() }}
                        <button class="confirm-button" id="delete-option"> <span class="material-icons">delete</span> </button>
                    </form>
                </div>     
                @else
                <div id="review-edit-options">
                    <form method="POST" id="delete-form-container" action="{{route('submitReport')}}"> 
                        {{ csrf_field() }}
                        <input name="user_id" value="{{$review['reviewer_id']}}" hidden>
                        <button class="confirm-button" id="delete-option"> <span class="material-icons">flag</span> </button>
                    </form>
                    @if (Auth::check() && Auth::user()->is_admin)
                        <form method="POST" id="delete-form-container" action="{{route('deleteReview', ['user_id' => $review['reviewer_id'], 'product_id' => $review['product_id']])}}"> 
                            {{ csrf_field() }}
                            <button class="confirm-button" id="delete-option"> <span class="material-icons">delete</span> </button>
                        </form>
                    @endif
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

