const collapsible = document.getElementById("collapsible");
const filters = document.getElementById("filters");
const results = document.getElementsByClassName("results-wrapper")[0];

collapsible.addEventListener("click", () => {
    if (filters.style.maxHeight) {
        filters.dataset.show = "false";
        filters.style.maxHeight = null;
        filters.style.padding = "0px";
        results.style.display = "block";
    } else {
        filters.dataset.show = "true";
        filters.style.maxHeight = filters.scrollHeight + 50 + "px";
        filters.style.padding = "25px";
        results.style.display = "none";
    }
});

window.addEventListener("resize", () => {
    if (filters.dataset.show == "true" && window.innerWidth >= 768) {
        filters.dataset.show = "false";
        filters.style.maxHeight = null;
        filters.style.padding = "25px";
        results.style.display = "block";
    } else if (filters.dataset.show == "false" && window.innerWidth < 768) {
        filters.style.padding = "0px";
    }
    if (window.innerWidth >= 768) {
        filters.style.padding = "25px";
    } else if (window.innerWidth < 768) {
        filters.style.padding = "0px";
    }
});
