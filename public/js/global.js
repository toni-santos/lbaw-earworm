let hamburger = document.getElementById('hamburger');
let hamburgerIcon = document.getElementById('hamburger-icon');
let content = document.getElementById('mobile-content');
let obscure = document.getElementById('obscure-bg');

const hamburgerAnimate = [
  { transform: 'translateY(-200%)' },
  { transform: 'translateY(0%)' },
];

const profileAnimate = hamburgerAnimate;

const obscureAnimate = [
  { opacity: '0%' },
  { opacity: '40%' },
];

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
    content.animate(hamburgerAnimate, timingsAnimateForward);
    obscure.animate(obscureAnimate, timingsAnimateForward);
  } else {
    hamburger.dataset.show = "false";
    hamburgerIcon.innerHTML = "menu";
    content.animate(hamburgerAnimate, timingsAnimateBackward).reverse();
    obscure.animate(obscureAnimate, timingsAnimateBackward).reverse();
  }
});

window.addEventListener('resize', () => {
  if (hamburger.dataset.show == "true" && window.innerWidth >= 768) {
    hamburger.dataset.show = "false";
    hamburgerIcon.innerHTML = "menu";
    content.animate(hamburgerAnimate, timingsAnimateBackward).reverse();
    obscure.animate(obscureAnimate, timingsAnimateBackward).reverse();
  }
});