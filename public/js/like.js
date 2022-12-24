"use strict"

async function toggleLike(event, id) {

    const input = event.composedPath();
    
    var like_container = document.getElementById('favorite-container-' + id);
    let like = document.querySelector('#favorite-container-' + id + ' > span');
    if (like.textContent == "favorite_outline") {
        if (like_container.firstChild.data == "Add to Wishlist") like_container.firstChild.data = "Wishlisted";
        like.textContent = "favorite";

        const response = await fetch(`/wishlist/add/${id}`, {
            method: "POST",
            credentials: 'include',
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
            }
        });
        const success = await response.json();
        console.log(success);

    } else {
        if (like_container.firstChild.data == "Wishlisted") like_container.firstChild.data = "Add to Wishlist";
        like.textContent = "favorite_outline";

        const response = await fetch(`/wishlist/remove/${id}`, {
            method: "POST",
            credentials: 'include',
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
            }
        });

        let card = document.querySelector(`.wishlist-card-top-${id}`);
        if (card) 
           card.remove();

        const success = await response.json();
        console.log(success);
        
    }
}