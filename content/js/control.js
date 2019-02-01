console.clear();


async function updateControl(ctl) {
    get_http_data(window.location.origin + '/control=' + ctl);
    if (ctl == "reload"){
      await sleep(500);
      get_http_data(window.location.origin + '/control=' + "pause");
      document.getElementById('play').checked
    };
}


function get_http_data(url) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", url, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200 ) {
            console.log(xhttp.responseText);
//            document.getElementById(target).innerHTML = xhttp.responseText;
          };
        };
    xhttp.send();
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}
