new Flickity("#carousel-lastfm-recs", {
    draggable: true,
    wrapAround: true,
    groupCells: "100%",
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: true,
    resize: true,
    cellSelector: ".product-card",
});

new Flickity("#carousel-fav-artists", {
    draggable: true,
    wrapAround: true,
    groupCells: "100%",
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: true,
    resize: true,
    cellSelector: ".artist-card",
});

window.onload = function() {
    let background = document.getElementById('user-banner');
    let image = document.getElementById("user-pfp");

    let canvas = document.createElement("canvas");
    canvas.width = image.offsetWidth
    canvas.height = image.offsetHeight

    let context = canvas.getContext('2d')
    context.drawImage(image,0,0);

    let color = context.getImageData(0, 0, 1, 1).data
    background.style.backgroundImage = `linear-gradient(to bottom, rgb(${color[0]},${color[1]},${color[2]}), var(--white))`;

}

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
