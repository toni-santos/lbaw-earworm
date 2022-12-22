let hamburger = document.getElementById("hamburger");
let hamburgerIcon = document.getElementById("hamburger-icon");
let content = document.getElementById("mobile-content");
let obscure = document.getElementById("obscure-bg");
let body = document.getElementsByTagName("body")[0];
let html = document.getElementsByTagName("html")[0];
let newTopPosition = 0;

let hamburgerAnimate = [
    { transform: "translateY(-200%)" },
    { transform: "translateY(0%)" },
];

const profileAnimate = hamburgerAnimate;

const obscureAnimate = [{ opacity: "0%" }, { opacity: "60%" }];

const timingsAnimateForward = {
    duration: 600,
    iterations: 1,
    fill: "forwards",
};

const timingsAnimateBackward = {
    duration: 600,
    iterations: 1,
    fill: "backwards",
};

hamburger.addEventListener("click", () => {
    if (hamburger.dataset.show == "false") {
        hamburger.dataset.show = "true";
        hamburgerIcon.innerHTML = "close";
        body.style.overflow = "hidden";
        body.style.height = "100%";
        html.style.overflow = "hidden";
        updateObscurePosition(window.scrollY);
        content.animate(hamburgerAnimate, timingsAnimateForward);
        obscure.animate(obscureAnimate, timingsAnimateForward);
    } else {
        hamburger.dataset.show = "false";
        hamburgerIcon.innerHTML = "menu";
        body.style.overflow = "scroll";
        body.style.height = "auto";
        html.style.overflow = "scroll";
        obscure.style.top = "-200%";
        content.animate(hamburgerAnimate, timingsAnimateBackward).reverse();
        obscure.animate(obscureAnimate, timingsAnimateBackward).reverse();
    }
});

window.addEventListener("resize", () => {
    if (hamburger.dataset.show == "true" && window.innerWidth >= 768) {
        hamburger.dataset.show = "false";
        hamburgerIcon.innerHTML = "menu";
        body.style.overflow = "scroll";
        body.style.height = "auto";
        html.style.overflow = "scroll";
        content.animate(hamburgerAnimate, timingsAnimateBackward).reverse();
        obscure.animate(obscureAnimate, timingsAnimateBackward).reverse();
    }
});

window.addEventListener("scroll", () => {
    updateNavContentPosition(window.scrollY);
});

function updateObscurePosition(pos) {
    obscure.style.top = pos + "px";
}

function updateNavContentPosition(pos) {
    hamburgerAnimate = [
        { transform: "translateY(-200%)" },
        { transform: "translateY(" + pos + "px)" },
    ];
}

function validateForm() {
    const searchForm = document
        .getElementById("search-form")
        .getElementsByTagName("input");
    const filterForm = document
        .getElementById("filters-form")
        .getElementsByTagName("input");

    for (const input of searchForm) {
        console.log(input);
        if (input.value == "") {
            input.name = "";
        }
    }
    for (const input of filterForm) {
        console.log(input);
        if (input.value == "" || (input.type == "checkbox" && !input.checked)) {
            input.name = "";
        }
    }
    return true;
}
