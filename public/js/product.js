// CAROUSEL
new Flickity('#carousel-product', {
    draggable: true,
    wrapAround: true,
    groupCells: '100%',
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: true,
    resize: true,
    cellSelector: '.product-card',
});

// Tilt effect

const tl_wrapper = document.getElementById('product-tracklist');
let tl_array = tl_wrapper.split('\n');
tl_array.forEach(track => {
    let track_par = createElement('p');
    track_par.classList.add('track');
    track_par.innerText = track;
    tl_wrapper.appendChild(track_par);
}); 

function selectStar(event) {
    const star_container = event.composedPath()[2];
    const rating = event.composedPath()[1].id.split('-')[2];

    star_container.querySelector('#star-' + rating).checked = true;

    for (let i = 0; i < 5; i++) {
        let star = star_container.querySelector('#star-label-' + i + ' > span');

        if (i <= rating) {
            star.textContent = "star";
        } else {
            star.textContent = "star_outline";
        }
            
    }
}

// edit review dropdown

function toggleEditReview(event, id) {
    const review_bot = document.getElementById("review-edit-bot");
    const prev_review = document.getElementById(`review-message-${id}`);
    if (review_bot.style.maxHeight) {
        review_bot.style.maxHeight = null;
        prev_review.style.maxHeight = prev_review.scrollHeight + 5 + "px";
        prev_review.style.paddingTop = "5px";
    }
    else {
        review_bot.style.maxHeight = review_bot.scrollHeight + "px";;
        prev_review.style.maxHeight = '0px';
        prev_review.style.paddingTop = "0px";
    }
}
