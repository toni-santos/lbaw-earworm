function toggleFAQSection(section, id) {
    const section_bot = document.querySelector(`#faq-section-bot-${section}`);
    const content_bot = document.querySelector(`#faq-drop-top-${section}-1`);

    if (section_bot.style.maxHeight) {
        section_bot.style.maxHeight = null;
    } else {
        section_bot.style.maxHeight = 2 * content_bot.scrollHeight + 32 + "px";
    } 
}

function toggleFAQ(section, id) {
    const faq_bot = document.querySelector(`#faq-drop-bot-${section}-${id}`);
    const faq_content = document.querySelector(`#faq-drop-bot-${section}-${id} div`);
    const section_bot = document.querySelector(`#faq-section-bot-${section}`);
    
    if (faq_bot.style.maxHeight) {
        faq_bot.style.maxHeight = null;
        faq_bot.style.marginBlock = "0px";
        faq_bot.style.paddingBlock = "0px";
        
    } else {
        faq_bot.style.maxHeight = faq_content.scrollHeight + 36 + "px" ;
        faq_bot.style.marginBlock = "8px";
        faq_bot.style.paddingBlock = "10px";
        section_bot.style.maxHeight = faq_content.scrollHeight + 36 + faq_bot.style.maxHeight.slice(0, -2) + "px";
        console.log(style.maxHeight);
    } 
}