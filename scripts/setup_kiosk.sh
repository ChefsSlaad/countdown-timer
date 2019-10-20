#!/bin/bash

#################################
# configuration script that will#
# turn a raspberry pi into an   #
# kiosk                         #
#################################

ROTATE=0 # screen rotation. 0 = normal 1=90 degrees clockwise 2=180 degrees clockwise, etc..
URLS=""

parameters()
{
    echo "using the following parameters:"
    echo "rotate = $ROTATE"
    echo "urls   = $URLS"
}

#################################
# usage message                 #
#################################

usage()
{
    echo "usage $0 [-o 0|90|180|270|360 ] [-u <url> <url2> ...]"
    echo "      $0 [-u <url 1> <url 2> .... <url n>]"
}

#################################
# checking for root priveledges #
#################################

if [ "$EUID" -ne 0 ]
	then echo "you must have root access to run this script"
         echo "try sudo $0"
	exit 1
fi

#################################
# checking correct arguments    #
# and setting them              #
#################################


check_valid_url()
{
    regex='^(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
    if [[ $1 =~ $regex ]]
        then return
    fi
    echo "$1 is not a valid URL" 
    exit 1
}
    
while [ "$1" != "" ]; do
    case $1 in
        -o)    shift
               case $1 in 
                   -o|-u|'')      echo "missing argument after -o"
                                  usage
                                  exit 1 ;;
                   0|360)         ROTATE=0;;
                   90)            ROTATE=1;;
                   180)           ROTATE=2;;
                   270)           ROTATE=3;;
                   *)             echo "incorrect agrument after -o" 
                                  usage
                                  exit 1
               esac
               shift;;

        -u)    shift
               case $1 in 
                   -o|-u|'')      echo "missing argument after -u"
                                  usage
                                  exit 1 ;;
                   *)             while [ "$1" != "" ]; do
                                      case $1 in -o|-u) break;; esac
                                      check_valid_url $1
                                      URLS="$URLS $1"
                                  shift
                                  done

               esac ;;

        *)     usage
               exit 0
    esac
done

if [[ -z $URLS ]]
    then URLS="http://127.0.0.1"
fi
parameters

###################################
#      install and unistall apps  #
###################################

apt-get -qqy update 
apt-get -qqy upgrade
apt-get -qqy install curl xdotool unclutter sed x11vnc


#####################################
# set screen in correct orientation #
#####################################

cat >> /boot/config.txt <<EOF

# configuration for kiosk
display_rotate=$ROTATE
avoid_warnings=1
EOF



#####################################
# set desktop bgcolor and screen    #
# icons                             #
#####################################


pcmanfm_conf="/home/pi/.config/pcmanfm/LXDE-pi/desktop-items-0.conf"

sed -i '/wallpaper_mode/c\wallpaper_mode=color' $pcmanfm_conf
sed -i '/desktop_bg/c\desktop_bg=#000000000000' $pcmanfm_conf
sed -i '/desktop_fg/c\desktop_fg=#000000000000' $pcmanfm_conf
sed -i '/desktop_shadow/c\desktop_shadow=#000000000000' $pcmanfm_conf
sed -i '/show_documents/c\show_documents=0' $pcmanfm_conf
sed -i '/show_trash/c\show_trash=0' $pcmanfm_conf
sed -i '/show_mounts/c\show_mounts=0' $pcmanfm_conf

## to change the splash screen:
# replace the file splash.png with your own.
# remember to keep the name splash.png

# /usr/share/plymouth/themes/pix/splash.png


#####################################
#     installing services           #
#    and setting up scripts         #
#####################################

mkdir -p /home/pi/kiosk/

cat > /home/pi/kiosk/kiosk.sh <<EOF
#!/bin/bash

URL="$URLS"
xset s noblank
xset s off
xset -dpms

sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/pi/.config/chromium/Default/Preferences
sed -i 's/"exit_type":"Crashed"/"exit_type":"Normal"/' /home/pi/.config/chromium/Default/Preferences

unclutter -idle 0.5 -root &

/usr/bin/chromium-browser --noerrdialogs --disable-infobars --kiosk \$URL &
EOF

chmod +x /home/pi/kiosk/kiosk.sh


# check if URLS has 2 or more values. If so add a tab shifting function

spaces=" |'"
if [[ "$string" =~ $spaces ]]
    then cat >> ~kiosk/kiosk.sh <<EOF
         while true; do
             xdotool keydown ctrl+Tab; xdotool keyup ctrl+Tab;
             sleep 15
         done
EOF
fi
#####################################
#       autostart an boot           # 
#####################################

sed -i '/@xscreensaver -no-splash/c\#@xscreensaver -no-splash' /etc/xdg/lxsession/LXDE-pi/autostart
cat >> /etc/xdg/lxsession/LXDE-pi/autostart <<EOF

# start the kiosk script
@bash /home/pi/kiosk.sh
EOF
