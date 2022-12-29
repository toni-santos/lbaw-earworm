async function toggleArtistLike(event, id) {
    let like = document.querySelector('#favorite-artist-container-' + id);
    if (like.textContent == "favorite_outline") {
        like.textContent = "favorite";

        const response = await fetch(`/fav-artist/add/${id}`, {
            method: "POST",
            credentials: 'include',
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
            }
        });
        const success = await response.json();

    } else {
        like.textContent = "favorite_outline";

        const response = await fetch(`/fav-artist/remove/${id}`, {
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

    }   
}
