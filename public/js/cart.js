"use strict"

async function decreaseAmountCart(event, id) {
    const input = event.composedPath()[1].children[1];
    const removable = event.composedPath()[3];
    const sideValueRemovable = document.getElementById('item-desc-' + id);
    const sideValue = document.querySelector(`#item-desc-${id} > a:last-child > span`);
    
    if (parseInt(input.textContent) == 1) {
        removeItemCart(event, id);

    } else if (parseInt(input.textContent) >= 2) {
        const response = await fetch(`/cart/decrease/${id}`, {
            method: "POST",
            credentials: 'include',
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
            }
        });
        const success = await response.json();
        
        input.textContent = parseInt(input.textContent) - 1;
        document.querySelectorAll(`#cart-item-desc-${id} > cart-item-amnt p`).textContent = input.textContent;
    }
}

async function increaseAmountCart(event, id) {
    const input = event.composedPath()[1].children[1];
    console.log(input);

    if (parseInt(input.textContent) < 98) {
        
        const response = await fetch(`/cart/increase/${id}`, {
            method: "POST",
            credentials: 'include',
            headers: {
                "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
            }
        });

        const success = await response.json();
        console.log(success);

        input.textContent = parseInt(input.textContent) + 1;
        document.querySelectorAll(`.cart-item-${id} .cart-item-amnt`)[0].children[1].textContent = input.textContent;
    }
}

async function removeItemCart(event, id) {

    const response = await fetch(`/cart/remove/${id}`, {
        method: "POST",
        credentials: 'include',
        headers: {
            "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
        }
    });
    const success = await response.json();

    
    document.querySelector(`.cart-item-${id}`).remove();
}
