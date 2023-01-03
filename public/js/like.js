"use strict";

async function toggleLike(event, id) {
    var like_container = document.getElementById("favorite-container-" + id);
    let like = document.querySelector("#favorite-container-" + id + " > span");
    if (like.textContent == "favorite_outline") {
        const response = await fetch(`/wishlist/add/${id}`, {
            method: "POST",
            credentials: "include",
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content,
            },
        });
        if (response.redirected) {
            try {
                throw new Error("Only regular users can do that.");
            } catch (error) {
                console.error(`${error.message}`);
            }
            return;
        }
        if (like_container.firstChild.data == "Add to Wishlist")
            like_container.firstChild.data = "Wishlisted";
        like.textContent = "favorite";
        const success = await response.json();
    } else {
        const response = await fetch(`/wishlist/remove/${id}`, {
            method: "POST",
            credentials: "include",
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content,
            },
        });
        if (response.redirected) {
            try {
                throw new Error("Only regular users can do that.");
            } catch (error) {
                console.error(`${error.message}`);
            }
            return;
        }
        if (like_container.firstChild.data == "Wishlisted")
            like_container.firstChild.data = "Add to Wishlist";
        like.textContent = "favorite_outline";

        let card = document.querySelector(`.wishlist-card-top-${id}`);
        if (card) card.remove();
        const success = await response.json();
    }
}
