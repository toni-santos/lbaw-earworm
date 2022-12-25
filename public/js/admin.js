function expandOptions(event, id) {
    const bottom = document.querySelector('.result-bot-' + id);
    if (bottom.style.display == 'none') {
        bottom.style.display = 'flex';
    } else {
        bottom.style.display = 'none';
    }
}