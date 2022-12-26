
function expandOptions(event, id) {
    const bottom = document.querySelector('.result-bot-' + id);
    const bottomContent = document.querySelector('.result-bot-' + id  + ' div');

    if (bottom.style.maxHeight) {
        bottom.dataset.show = "false";
        bottom.style.maxHeight = null;
        bottom.style.paddingInline = "0px";
        bottom.style.paddingBlock = "0px";
    } else {
        bottom.dataset.show = "true";
        bottom.style.maxHeight = bottomContent.scrollHeight + 80 + "px";
        bottom.style.paddingInline = "40px";
        bottom.style.paddingBlock = "30px";
    }
}