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
    cellSelector: ".product-card",
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
