"use strict"

async function decreaseAmount(event) {
    const input = event.composedPath()[1].children[1];
    const removable = event.composedPath()[3];
    const sideValueRemovable = document.getElementById('item-desc-' + event.composedPath()[3].id.split('-')[2]);
    const sideValue = document.querySelector(`#item-desc-${event.composedPath()[3].id.split('-')[2]} > a:last-child > span`);
    
    if (parseInt(input.textContent) == 1) {
        removeItemDecreasing(removable, sideValueRemovable);
    } else if (parseInt(input.textContent) >= 2) {
        input.textContent = parseInt(input.textContent) - 1;
        sideValue.textContent = input.textContent;
    }
   
    updateTotal();
}

async function increaseAmount(event) {
    const input = event.composedPath()[1].children[1];

    if (parseInt(input.textContent) < 98) {
        input.textContent = parseInt(input.textContent) + 1;
        document.querySelector(`#item-desc-${event.composedPath()[3].id.split('-')[2]} > a:last-child > span`).textContent = input.textContent;
    }

    updateTotal();
}

async function removeItem(event) {
    event.composedPath()[2].remove();
    document.getElementById('item-desc-' + event.composedPath()[2].id.split('-')[2]).remove();

    updateTotal();
}

async function removeItemDecreasing(removable, sideValueRemovable) {
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
    const form = event.composedPath()[4];
    const button = document.getElementById('confirm-checkout')
    Object.values(form.children[0].getElementsByTagName("input")).forEach(element => {
        if (element.value.length != 0) {
            activate = true;
        }
    });

    if (activate) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }
}