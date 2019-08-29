function getLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(showPosition, defaultPosition);
    } else {
        console.log("Geolocation is not supported by this browser.");
    }
}

function showPosition(position) {
    createLinkOnPage(position.coords.latitude, position.coords.longitude);
}

function defaultPosition(position) {
    createLinkOnPage("37.388309", "-121.973968")
}

function createLinkOnPage(latitude, longitude) {
    document.getElementById('lds-roller').remove();
    var link = document.createElement('a');
    link.setAttribute('class', 'link_style');
    link.innerHTML = "Start";
    link.setAttribute('href', "/conversations?latitude=" + latitude + "&longitude=" + longitude);
    document.getElementById('link_to_start').appendChild(link);
}

getLocation();