#!/usr/bin/python3
from bottle import route, run, static_file
from time import sleep

run_state = "run"
valid_states = ("run", "pause","reload")


@route('/')
def index():
#    print('index requested')
    return static_file('index.html', root='content')

@route('/control=<command>')
def command(command):
    print('control function {} requested'.format(command))
    if command.lower() in valid_states:
        global run_state
        run_state = command.lower()



@route('/<filename:re:.*\.(html|css|js)$>')
def static_file_return(filename):
#    print('file {} requested'.format(filename))
    return static_file(filename, root='content')

@route('/run_state')
def return_state():
    global run_state
    return run_state


run (host='0.0.0.0', port=80, debug=True)
