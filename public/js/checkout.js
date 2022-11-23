"use strict"

async function decreaseAmountCheckout(event, id) {
    const input = event.composedPath()[1].children[1];
    const removable = event.composedPath()[3];
    const sideValue = document.querySelector(`#item-desc-${id} > a:last-child > span`);
    
    if (parseInt(input.textContent) == 1) {
        removeItemCheckout(event, id);

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
        sideValue.textContent = input.textContent;
        document.querySelector(`article#item-desc-${id} span:last-child`).textContent = input.textContent;
        updateTotal();
    }
}

async function increaseAmountCheckout(event, id) {
    const input = event.composedPath()[1].children[1];

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
        document.querySelector(`#checkout-item-${id} > .right-item > .right-item-top > a`).textContent = input.textContent;
        document.querySelector(`article#item-desc-${id} span:last-child`).textContent = input.textContent;
        
        updateTotal();
    }
}

async function removeItemCheckout(event, id) {

    const response = await fetch(`/cart/remove/${id}`, {
        method: "POST",
        credentials: 'include',
        headers: {
            "X-CSRF-Token": document.querySelectorAll(`meta`)[3].content
        }
    });
    const success = await response.json();

    document.querySelector(`#checkout-item-${id}`).remove();
    document.getElementById(`item-desc-${id}`).remove();

    updateTotal();

}

async function removeItemDecreasingCheckout(removable, sideValueRemovable) {
    removable.remove();
    sideValueRemovable.remove();

    updateTotal();
}

function updateTotal() {
    const items = document.querySelectorAll('.pay-desc-item');
    let total = 0;

    for (const item of items) {
        total += item.children[1].querySelector('span').textContent * item.children[1].textContent.split(' ')[1].slice(0, -1);
    }

    document.getElementById('checkout-value').textContent = (total).toFixed(2) + '€'; 
    const paymentDesc = document.getElementById('payment-description');
    const confirmButton = document.getElementById('confirm-checkout')
    if (paymentDesc.children.length == 0) {
        confirmButton.disabled = true;
    }
}

window.addEventListener('load', () => {
    updateTotal();
});

function checkDone(event) {
    // activate button
    let activate = false;
    const button = document.getElementById('confirm-checkout');
    const pm = document.getElementById('address');
    if (pm.value.length != 0) {
        activate = true;
    }

    if (activate) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }
}