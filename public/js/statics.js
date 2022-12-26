console.log("here");

async function toggleFAQSection(event, section) {
    section_bot = document.getElementById(`faq-section-bot-${section}`);
    if (section_bot.style.display == 'none') 
        section_bot.style.display = 'flex';
    else 
        section_bot.style.display = 'none';
}

console.log("here2");

async function toggleFAQ(event, section, id) {
    faq_bot = document.getElementById(`faq-drop-${section}-bot-${id}`);
    if (faq_bot.style.display == 'none') {
        faq_bot.style.display = 'flex';
    }
    else 
        faq_bot.style.display = 'none';
}