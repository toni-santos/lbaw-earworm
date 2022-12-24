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

function expandUserOptions(event, id) {
    switch (visible) {
        case infoSection:
            const info = document.querySelector('.user-bot-info-' + id);
            if (info.style.display == 'none') {
                info.style.display = 'flex';
            } else {
                info.style.display = 'none';
            }
        case passwordSection:
            const pass = document.querySelector('.user-bot-pass-' + id);
            if (pass.style.display == 'none') {
                pass.style.display = 'flex';
            } else {
                pass.style.display = 'none';
            }
        case lastfmSection:
            const lastfm = document.querySelector('.user-bot-lastfm-' + id);
            if (lastfm.style.display == 'none') {
                lastfm.style.display = 'flex';
            } else {
                lastfm.style.display = 'none';
            }
    }
}

// password checker -> USE FORMS.JS


