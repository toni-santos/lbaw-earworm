// carousels

// let carouselPromos = new Flickity('#carousel-promos', {
//     draggable: true,
//     wrapAround: true,
//     groupCells: false,
//     autoPlay: true,
//     dragThreshold: 10,
//     prevNextButtons: false,
//     resize: true
// });

let carouselTrending = new Flickity("#carousel-trending", {
    draggable: true,
    wrapAround: true,
    groupCells: "100%",
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: true,
    resize: true,
    cellSelector: ".product-card",
});

let carouselForYou = new Flickity("#carousel-fy", {
    draggable: true,
    wrapAround: true,
    groupCells: "100%",
    autoPlay: true,
    dragThreshold: 10,
    prevNextButtons: true,
    resize: true,
    cellSelector: ".product-card",
});

// navbar

const navbar = document.getElementById("navbar-wide");
const navbarInside = document.getElementById("wide-top");
const scrollCap = window.screen.height / 2;

window.addEventListener("scroll", () => {
    let scrollPercentage = window.scrollY / scrollCap;
    navbarInside.style.background = "rgba(28, 49, 94," + scrollPercentage + ")";
    if (window.scrollY >= scrollCap) {
        navbar.style.background = "var(--main-accent)";
    } else {
        navbar.style.background =
            "linear-gradient(0deg, rgb(0,0,0,0) 0%, rgb(0,0,0,0) 50%, rgba(24, 82, 41, 0.5) 100%)";
    }
});
