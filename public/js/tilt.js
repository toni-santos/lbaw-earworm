const tiltEls = document.querySelectorAll(".tilt");

const tiltMove = (x, y) =>
    `perspective(300px) rotateX(${x}deg) rotateY(${y}deg)`;

tiltEls.forEach((tilt) => {
    const height = tilt.clientHeight;
    const width = tilt.clientWidth;

    tilt.addEventListener("mousemove", (e) => {
        const x = e.layerX;
        const y = e.layerY;
        const multiplier = 7;

        const xRotate = multiplier * ((x - width / 2) / width);
        const yRotate = -multiplier * ((y - height / 2) / height);

        tilt.style.transform = tiltMove(yRotate, xRotate);
    });

    tilt.addEventListener(
        "mouseout",
        () => (tilt.style.transform = tiltMove(0, 0))
    );
});
