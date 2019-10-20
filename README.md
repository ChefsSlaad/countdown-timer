# countdown-timer

this is a simple timer that counts down a certain number of minutes. It is designed to run on a raspberry pi zero-w which can be hooked up to a monitor to display the timer. connect to de control page using another device (e.g. a phone) to start / stop / reset the timer

The device includes the following components:

* a simple webserver based on bottle that serves both the timer page and the the control page
* the timer page that counts down 
* the control page that allows you to start, stop, reset
* some configuration files for the pi
        * allow the pi to enter kiosk mode at startup
        * connect to wifi network


to-do's:
* duration should be adjustable thorugh the control page
* method to adjust the configuration of the access-point (e.g. atach to another aqccess point, change ssid and password)
* easy device naming... use alias when device is set as access-point

