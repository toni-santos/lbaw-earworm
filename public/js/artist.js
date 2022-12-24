import { bbcodeParser } from './BBCode_to_HTML.js';

new Flickity("#carousel-artist", {
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
    let background = document.getElementById('artist-banner');
    let image = document.getElementById("artist-pfp");

    let canvas = document.createElement("canvas");
    canvas.width = image.offsetWidth
    canvas.height = image.offsetHeight

    let context = canvas.getContext('2d')
    context.drawImage(image,0,0);

    let color = context.getImageData(0, 0, 1, 1).data
    background.style.backgroundImage = `linear-gradient(to bottom, rgb(${color[0]},${color[1]},${color[2]}), var(--white))`;

    let content = document.getElementById('artist-description');
    console.log(content)
    content.innerHTML = bbcodeParser.bbcodeToHtml(content.innerText);
}
