@switch($type)
    @case("profile")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <img alt="Product picture" src={{ url('/images/products/' . $review['product_id'] . '.jpg') }} class="reviewer-pfp"> </a>
                    <a href="{{ route('product', ['id' => $review['product_id']]) }}"> <p class="reviewer-name">{{$review['product']['name']}}</p> </a>
                    -
                    <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                    <p class="reviewer-date"> {{$review['date']}} </p>
                </div>
            </div>
            <article class="review-message">
                {{$review['message']}}
            </article>
        </section>
        @break
    @case("product")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <img alt="User profile picture" src={{ url('/images/users/' . $review['reviewer_id'] . '.jpg') }} class="reviewer-pfp">
                    <p class="reviewer-name">{{$review['reviewer']['username']}}</p>
                    -
                    <p class="reviewer-score subtitle1">{{$review['score']}}<span class="material-icons"  style="color:var(--star);">star</span></p>
                    <p class="reviewer-date"> {{$review['date']}} </p>
                </div>
            </div>
            <article class="review-message">
                {{$review['message']}}
            </article>
        </section>
        @break
    @default
        @break
@endswitch

