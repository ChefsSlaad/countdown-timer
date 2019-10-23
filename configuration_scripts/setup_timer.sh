#!/bin/bash

#################################
# configuration script that will#
# run a countdown timer which   #
# can be controlled using a     # 
# phone or other device         #
#################################


INSTALL_DIR=$PWD
TIMER_FILE="$INSTALL_DIR/countdown_timer/countdown.py"

#################################
# usage message                 #
#################################

usage()
{
    echo "usage $0 "
    echo "      this script performs the following actions:"
    echo "      *  download the lates version of the timer files (html/css/js)"
    echo "         from github"
    echo "      *  install a unit file that auto-launches the timer"

}

#################################
# checking for root priveledges #
# and extra arguments           #
#################################

if [ "$EUID" -ne 0 ]
	then echo "you must have root access to run this script"
         echo "try sudo $0"
	exit 1
fi

if [ "$1" != "" ]
    then usage
    exit 0
fi

#################################
# cloning files                 #
#################################

git clone git@github.com:marcwagner/countdown-timer.git

#################################
# setting up unit file          #
#################################
cat > /etc/systemd/system/countdown.service <<EOF
[Unit]
Description=start webserver displaying countdown info
After=network.target

[Service]
Type=simple
WorkingDirectory=$INSTALL_DIR/countdown_timer/
ExecStart=$TIMER_FILE
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

systemctl enable countdown.service
systemctl daemon-reload
systemctl start countdown.service




