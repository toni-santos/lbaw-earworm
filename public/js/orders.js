function expand(id) {
    const bottom = document.querySelector(`.order-bot-${id}`);
    const expand = document.getElementById(`order-expand-${id}`);

    if (bottom.style.maxHeight) {
        bottom.dataset.show = "false";
        bottom.style.maxHeight = null;
        bottom.style.padding = "0px";
        expand.textContent = "expand_more";
    } else {
        bottom.dataset.show = "true";
        bottom.style.maxHeight = bottom.scrollHeight + 20 + "px";
        bottom.style.padding = "10px";
        expand.textContent = "expand_less";
    }
}