@switch($type)
    @case("profile")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <img alt="Product picture" src="" class="reviewer-pfp">
                    <p class="reviewer-name">PRODUCT NAME</p>
                    -
                    <p class="reviewer-score subtitle1">RATING<span class="material-icons"  style="color:var(--star);">star</span></p>
                </div>
            </div>
            <article class="review-message">
                REVIEW
            </article>
        </section>
        @break
    @case("product")
        <section class="review">
            <div class="review-head">
                <div class="reviewer-info">
                    <img alt="User profile picture" src="" class="reviewer-pfp">
                    <p class="reviewer-name">USER NAME</p>
                    -
                    <p class="reviewer-score subtitle1">RATING<span class="material-icons"  style="color:var(--star);">star</span></p>
                </div>
            </div>
            <article class="review-message">
                REVIEW
            </article>
        </section>
        @break
    @default
        @break
@endswitch

