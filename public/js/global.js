let hamburger = document.getElementById("hamburger");
let hamburgerIcon = document.getElementById("hamburger-icon");
let bar = document.getElementById("navbar-mobile");
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
        bar.style.boxShadow = "none";
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
        bar.style.boxShadow = "0px -5px 50px 0px rgba(0,0,0,0.75)";
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

function validateForm(form) {
    const formInputs = form.getElementsByTagName("input");

    for (const input of formInputs) {
        if (input.value == "" || (input.type == "checkbox" && !input.checked)) {
            input.name = "";
        }
    }
    return true;
}


async function clearMessage(event, id) {
    event.preventDefault();
    document.querySelector(`.message-box-wrapper-${id}`).remove();
}

async function clearNotification(event, id) {
    event.preventDefault();
    const response = await fetch(`/notification/clear/${id}`, {
        method: "POST",
        credentials: 'include',
        headers: {
            "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
        }
    });
    const success = await response.text(); 
    console.log(success);

    try {
        document.querySelector(`.notification-card-${id}`).remove();
    }catch(e) {
        console.log(e);
    }
    try {
        document.querySelector(`.notification-dropdown-item-${id}`).remove();
    } catch (e) {
        console.log(e);
    }
}
