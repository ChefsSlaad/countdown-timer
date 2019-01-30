console.clear();


function updateControl(ctl) {
    get_http_data(window.location.origin + '/control=' + ctl);
}


function get_http_data(url) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", url, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200 &&  typeof target != 'undefined') {
            console.log(xhttp.responseText);
//            document.getElementById(target).innerHTML = xhttp.responseText;
          };
        };
    xhttp.send();
}
