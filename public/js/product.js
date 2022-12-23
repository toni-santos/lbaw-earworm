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

const tiltEls = document.querySelectorAll('.tilt')

const tiltMove = (x, y) => `perspective(300px) rotateX(${x}deg) rotateY(${y}deg)`

tiltEls.forEach(tilt => {
    const height = tilt.clientHeight
    const width = tilt.clientWidth

    tilt.addEventListener('mousemove', (e) => {
        const x = e.layerX
        const y = e.layerY
        const multiplier = 10

        const xRotate = multiplier * ((x - width / 2) / width)
        const yRotate = -multiplier * ((y - height / 2) / height)

        tilt.style.transform = tiltMove(xRotate, yRotate)
    })

    tilt.addEventListener('mouseout', () => tilt.style.transform = tiltMove(0, 0))
})

const tl_wrapper = document.getElementById('product-tracklist');
console.log(document.getElementById('product-tracklist'))
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