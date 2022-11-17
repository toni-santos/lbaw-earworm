// carousels

let carouselPromos = new Flickity('#carousel-promos', {
    draggable: true,
    wrapAround: true,
    groupCells: false,
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: false,
    resize: true
});

let carouselTrending = new Flickity('#carousel-trending', {
    draggable: true,
    wrapAround: true,
    groupCells: '100%',
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: false,
    resize: true,
    cellSelector: '.product-card',
});

let carouselForYou = new Flickity('#carousel-fy', {
    draggable: true,
    wrapAround: true,
    groupCells: '100%',
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: false,
    resize: true,
    cellSelector: '.product-card',
});
