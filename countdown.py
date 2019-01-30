#!/usr/bin/python3
from bottle import route, run, static_file

run_state = "run"
valid_states = ("run", "pause", "reset")


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
        print(run_state)

@route('/<filename:re:.*\.(html|css|js)$>')
def static_file_return(filename):
#    print('file {} requested'.format(filename))
    return static_file(filename, root='content')

@route('/run_state')
def return_state():
#    print('return_state')
    global run_state
    print(run_state, end = ' ')
    return run_state


run (host='0.0.0.0', port=80, debug=True)
