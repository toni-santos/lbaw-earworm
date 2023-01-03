
function expandOptions(event, id) {
    const bottom = document.querySelector('.result-bot-' + id);
    const expand = document.querySelector('.result-top-' + id + ' .expand > span');
    const bottomContent = document.querySelector('.result-bot-' + id  + ' div');

    if (bottom.style.maxHeight) {
        bottom.dataset.show = "false";
        bottom.style.maxHeight = null;
        bottom.style.paddingBlock = "0px";
        expand.textContent = 'expand_more';
    } else {
        expand.textContent = 'expand_less';
        bottom.dataset.show = "true";
        bottom.style.maxHeight = bottomContent.scrollHeight + 80 + "px";
        bottom.style.paddingBlock = "30px";
    }
}