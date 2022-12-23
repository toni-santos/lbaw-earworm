"use strict"

async function toggleLike(event, id) {

    const input = event.composedPath();
    
    const response = await fetch(`/wishlist/add/${id}`, {
        method: "POST",
        credentials: 'include',
        headers: {
            "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
        }
    });

    const success = await response.json();
    console.log(success);
    
}