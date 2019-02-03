#!/usr/bin/python3
from bottle import route, run, static_file
from time import sleep

run_state = "run"
duration = 300
valid_states = ("run", "pause","reload")


@route('/')
def index():
#    print('index requested')
    return static_file('index.html', root='content')

@route('/control=<command>')
def command(command):
    print('control function {} requested'.format(command))
    print(command)
    for com in command.split('&'):
        if com.lower() in valid_states:
            global run_state
            run_state = com.lower()
        elif com.isdigit():
            global duration
            duration = int(com)

@route('/<filename:re:.*\.(html|css|js)$>')
def static_file_return(filename):
#    print('file {} requested'.format(filename))
    return static_file(filename, root='content')

@route('/run_state')
def return_state():
    global run_state, duration
    response = run_state+'&'+str(duration)
    return response
run (host='0.0.0.0', port=80, debug=True)
