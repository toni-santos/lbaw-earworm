const tl_wrapper = document.getElementById('product-tracklist');
console.log(document.getElementById('product-tracklist'))
let tl_array = tl_wrapper.split('\n');
tl_array.forEach(track => {
    let track_par = createElement('p');
    track_par.classList.add('track');
    track_par.innerText = track;
    tl_wrapper.appendChild(track_par);
}); 
