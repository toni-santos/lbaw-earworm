const pwd = document.getElementById('password-input');

function updateForm(event) {
    checkFilled(event);
    checkDone(event);
}

function checkDone(event) {
    // activate button
    let activate = true;
    const form = event.composedPath()[3];
    const button = document.getElementById('confirm-button')
    Object.values(form.children[0].getElementsByTagName("input")).forEach(element => {
        if (element.value.length == 0) {
            activate = false;
        }
    });

    if (activate) {
        button.disabled = false;
    } else {
        button.disabled = true;
    }
}

function checkFilled(event) {
    // show warning
    const warning = event.composedPath()[1].lastElementChild;

    if (event.target.value.length == 0) {
        warning.style.opacity = "100%";
    } else {
        warning.style.opacity = "0%";
    }
}

function showPassword(event) {

    if (pwd.type === "password") {
        pwd.type = "text";
        event.target.textContent = "visibility_off";
    } else {
        event.target.textContent = "visibility";
        pwd.type = "password";
    }
}

function updateCounter(event) {
    const cnt = event.composedPath()[1].children[3];

    cnt.textContent = event.target.value.length + "/8" ;
}

function setFocus(event) {
    const el = event.composedPath()[1].children[0];
    
    el.focus();
}