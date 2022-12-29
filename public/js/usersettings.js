//navbar interaction 

const infoTag = document.querySelector('#info-tag')
const passwordTag = document.querySelector('#password-tag')
const lastfmTag = document.querySelector('#lastfm-tag')

const infoSection = document.querySelector("#info-section")
const passwordSection = document.querySelector("#password-section")
const lastfmSection = document.querySelector("#lastfm-section")

const sections = Array(infoSection, passwordSection, lastfmSection)

let visible = infoSection;
let selected = infoTag;
let height = 0;
switchSection(infoSection, infoTag);

infoTag.addEventListener('click', () => {
  switchSection(infoSection, infoTag)
})

passwordTag.addEventListener('click', () => {
  switchSection(passwordSection, passwordTag)
})

lastfmTag.addEventListener('click', () => {
  switchSection(lastfmSection, lastfmTag)
})

function switchSection(newVisible, newSelected) {
    visible.setAttribute("hidden", "")
    newVisible.removeAttribute("hidden")
    visible = newVisible;
  
    selected.classList.remove("selected")
    newSelected.classList.add("selected")
    selected = newSelected
}

// forms js

function expandUserOptions(event, section, id) {
    switch (visible) {
        case infoSection:
            const info = document.querySelector('.user-bot-info-' + section + '-' + id);
            height = 0;
            for (let child of info.children) {
                height += child.offsetHeight;
            }
            if (info.style.maxHeight) {
                info.style.maxHeight = null;
                info.style.paddingTop = '0px';
            } else {
                info.style.maxHeight = height + 10 + 'px';
                info.style.paddingTop = '10px';
            }
            break;
        case passwordSection:
            const pass = document.querySelector('.user-bot-pass-' + section + '-' + id);
            height = 0;
            for (let child of pass.children) {
                height += child.offsetHeight;
            }
            if (pass.style.maxHeight) {
                pass.style.maxHeight = null;
            } else {
                pass.style.maxHeight = height + 10 + 'px';
            }
            break;
        case lastfmSection:
            const lastfm = document.querySelector('.user-bot-lastfm-' + section + '-' + id);
            height = 0;
            for (let child of lastfm.children) {
                height += child.offsetHeight;
            }
            if (lastfm.style.maxHeight) {
                lastfm.style.maxHeight = null;
            } else {
                lastfm.style.maxHeight = height + 10 + 'px';
            }
            break;

    }
}

// password checker -> USE FORMS.JS


