console.clear();

var run_state = "run";// options should be run, reset or pause
var countdownTime = 300 * 1000;// mseconds the countdown should take
var red_zone = 30 *1000; //ms the screen should flash red if the time is about to elapse


function updateControl(ctl) {
  get_run_state(window.location.origin + '/control=' + ctl);
//  console.log(ctl)
  run_state = ctl;
}

function get_run_state(url) {
    var xhttp = new XMLHttpRequest();
    xhttp.open("GET", url, true);
    xhttp.onreadystatechange = function() {
        if (xhttp.readyState == 4 && xhttp.status == 200 ) {
//            console.log(xhttp.responseText);
            run_state = xhttp.responseText;
          };
        };
    xhttp.send();
}


function CountdownTracker(label, value){
// this function creates a minute / second flipclock element as well as
// an update method ensures the last two digits for the time (minutes/seconds)
// remaining are presented correctly and that flips to the next value
// the update method is called at the end of the function so that the clock shows
// the correct time.
  var el = document.createElement('span');

  el.className = 'flip-clock__piece';
  el.innerHTML = '<b class="flip-clock__card card"><b class="card__top"></b><b class="card__bottom"></b><b class="card__back"><b class="card__bottom"></b></b></b>' +
    '<span class="flip-clock__slot">' + label + '</span>';

  this.el = el;

  var top = el.querySelector('.card__top'),
      bottom = el.querySelector('.card__bottom'),
      back = el.querySelector('.card__back'),
      backBottom = el.querySelector('.card__back .card__bottom');

  this.update = function(val){
    val = ( '0' + val ).slice(-2);
    if ( val !== this.currentValue ) {

      if ( this.currentValue >= 0 ) {
        back.setAttribute('data-value', this.currentValue);
        bottom.setAttribute('data-value', this.currentValue);
      }
      this.currentValue = val;
      top.innerText = this.currentValue;
      backBottom.setAttribute('data-value', this.currentValue);

      this.el.classList.remove('flip');
      void this.el.offsetWidth;
      this.el.classList.add('flip');
    }
  }
  this.update(value);
}

function getTimeRemaining(endtime) {
// returns number of minutes and seconds remain, based on the endtime provided
  var t = endtime;
  return {
    'Total': t,
    'Minutes': Math.floor((t / 1000 / 60) % 60),
    'Seconds': Math.floor((t / 1000) % 60)
  };
}

function Clock(countdown,red_zone,callback) {
//
  callback = callback || function(){};

  this.el = document.createElement('div');
  this.el.className = 'flip-clock';

  var trackers = {},
      t = getTimeRemaining(countdown),
      key, timeinterval;
// create a flipclock element for minutes and seconds remaining
  for ( key in t ){
    if ( key === 'Total' ) { continue; }
    trackers[key] = new CountdownTracker(key, t[key]);
    this.el.appendChild(trackers[key].el);
  }

  this.updateClock = function(new_countdown) {
    countdown -= 1000
    countdown = new_countdown ? new_countdown : countdown;
    var t = getTimeRemaining(countdown);
    if ( t.Total < 0 ) {
      for ( key in trackers ){
        trackers[key].update( 0 );
      }
      callback();
      return;
    }
    else if (t.Total <= red_zone) {
      if ( ( t.Total/1000 ) % 2 == 1 ) {document.body.classList.add("red_allert")} //turn red on unevent seconds past red_allert tiem
      else {document.body.classList.remove("red_allert")};
    }
    for ( key in trackers ){
      trackers[key].update( t[key] );
    }
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function runmany(c) {
  await sleep(1000);
  var update_ready = true;
  while (true) {
    switch (run_state) {
      case "run":
        c.updateClock();
        document.getElementById("run").checked = true;
        break;
      case "pause":
        document.getElementById("pause").checked = true;
        break;
      case "reload":
        c.updateClock(countdownTime);
        document.body.classList.remove("red_allert");
        document.getElementById("reload").checked = true; // after reset immediately start running
//        run_state = "run";
        break;
      }
    get_run_state(window.location.origin + '/run_state', );
    await sleep(1000);
    }
}

var c = new Clock(countdownTime, red_zone, function(){});
document.body.appendChild(c.el);
runmany(c)
