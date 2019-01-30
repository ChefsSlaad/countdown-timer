console.clear();


function updateControl(ctl) {
    get_http_data(window.location.origin + '/set_run_state=' + ctl);
}


function get_http_data(url) {
  var xhttp = new XMLHttpRequest();
  xhttp.onreadystatechange = function() {
    if (this.readyState == 4 && this.status == 200) {
     updateControl(this.responseText);
    }
  };
  xhttp.open("GET", url, true);
  xhttp.send();
}
