#!/bin/bash

############################
# script that will guide a #
# user through the install #
# of the countdown timer   #
############################

ENABLE_AP=0
SSID=NONE
PASS=NONE

ORIENTATION=0
URL=""


welcome()
{

    if [ "$EUID" -ne 0 ]
	    then whiptail --msgbox "you must have root access to run this script try sudo $0" 10 45
        exit 1
    fi

    if (whiptail \
        --title "Welcome" \
        --yesno "this program will guide you through the \
                  install of your countdown timer" 8 45 \
        --yes-button "continue" \
        --no-button "cancel")
        then
            configure_accespoint        
        else 
            echo 'exiting' 
            exit 0
    fi
}


configure_accespoint()
{
    SSID=NONE
    PASS=NONE
    if (whiptail \
    --title "Configuring accespoint" \
    --yesno "Would you like to configre your pi as an accesspoint? \nAnswering yes means that the pi will need a wired ethernet connection to be connected to the internet" 12 45 \
    --no-button "Cancel")
    then
        ENABLE_AP=1        
        SSID=$(whiptail \
            --title "SSID" \
            --inputbox "please enter the SSID you would like to use" 8 45 "PI" \
            --nocancel\
            3>&1 1>&2 2>&3)

        PASS=$(whiptail \
            --title "PASSWORD" \
            --inputbox "please enter the password you would like to use" 8 45 "raspberry" \
            --nocancel \
            3>&1 1>&2 2>&3)

        whiptail \
            --title "results" \
            --yesno "using the following configuration: \nSSID     $SSID\nPASSWORD $PASS\n\nIs this correct?" 12 45
            if [ $? == 1 ]; then configure_accespoint
            else configure_orientation
            fi
    else
        configure_orientation
    fi
}

configure_orientation()
{
    ORIENTATION=$(whiptail \
        --title "select screen orientation" \
        --radiolist "which side of the screen will be top" 14 45 6 \
        "0"   "the top - duh" ON \
        "90"  "the right side" OFF \
        "180" "the bottom" OFF\
        "270" "the left side" OFF \
        3>&1 1>&2 2>&3)
    configure_urls  
}

configure_urls()
{
#    valid_url='@(https?|ftp)://(-\.)?([^\s/?\.#-]+\.?)+(/[^\s]*)?$@iS' 
    valid_url='(https?|ftp)://'
    URL=$(whiptail \
        --title "URLs" \
        --inputbox "what url or page should be displayed?\nLeave empty to display the default page on this device or to stop adding URLS" 12 45  \
        --nocancel \
        3>&1 1>&2 2>&3)
    if [ -z $URL ]; then 
        whiptail \
        --yesno "I have collected the following urls: $URLS" 18 45 \
        --no-button "Restart" 
        if [ $? == 1 ]; then
            URLS=''
            configure_urls
        fi
    elif [[ $URL =~ $valid_url ]]; then
        read -r URLS <<<"$URLS $URL" # trim leading and trailing whitespaces / newline characters
        configure_urls
    else
        whiptail \
        --msgbox "$URL\ndoes not seem to be a valid URL please check re-enter a valid URL" 12 45 \
        --nocancel
    configure_urls
    fi
    
    echo $URLS
}

done()
{
    whiptail --infobox "setup done. Thank you" 8 45
}


welcome
if [ENABLE_AP = 1]; then configuration_scripts/setup_ap.sh -a $SSID -p $PASS; fi
configuration_scripts/setup_kiosk.sh -o $ORIENTATION -u $URLS
configuration_scripts/setup_timer.sh
done
