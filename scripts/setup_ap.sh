#!/bin/bash

#################################
# configuration script that will#
# turn a raspberry pi into an   #
# access point                  #
#################################

# based on https://www.raspberrypi.org/documentation/configuration/wireless/access-point.md

#################################
# usage message                 #
#################################

usage()
{
    echo "usage $0 [-a <accesspoint>] [-p <password>]"
}

#####################
# setting variables #
#####################

AP_SSID="MyAccesspoint"
AP_PASS="MyPassword"



show_config()
{
    echo "setting up access point on this device" 
    echo "using the following configuration:"
    echo "SSID:     $AP_SSID"
    echo "PASSWORD: $AP_PASS"
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

while [ "$1" != "" ]; do
    case $1 in
        -a)    shift
               case $1 in 
                   -a|-p|'')   echo "missing argument after -a"
                                  usage
                                  exit 1 ;;
                   *)             AP_SSID=$1
               esac ;;

        -p)    shift
               case $1 in 
                   -a|-p|'')   echo "missing argument after -p"
                                  usage
                                  exit 1 ;;
                   *)             if [ ${#1} -ge 8 ]
                                  then
                                      AP_PASS=$1
                                  else
                                      echo 'password should be 8 characters or more'
                                      exit 1
                                  fi ;;
               esac ;;
        *)     usage
               exit 0
    esac
    shift
done

show_config

# installing packages

apt-get -yqq remove --purge hostapd
apt-get -yqq updateqq
apt-get -yqq upgrade
apt-get -yqq install hostapd dnsmasq nfs-kernel-server


# stopping services

systemctl stop dnsmasq
systemctl stop hostapd

# configuring dhcpcd

cat >> /etc/dhcpcd.conf <<EOF

interface wlan0
    static ip_address=10.0.1.1/24
    nohook wpa_supplicant
EOF

service dhcpcd restart

# configuring dnsmasq. 

cat >> /etc/dnsmasq.conf <<EOF

interface=wlan0
dhcp-range=10.0.1.100,10.0.1.150,255.255.255.0,12h
EOF

systemctl reload dnsmasq


# configure hostapd 

cat >> /etc/hostapd/hostapd.conf <<EOF
interface=wlan0
driver=nl80211
ssid=$AP_SSID
hw_mode=g
channel=11
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$AP_PASS
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# link hostapd conf file
sed -i -- 's/^#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd

#restart hostapd
systemctl unmask hostapd
systemctl enable hostapd
systemctl start hostapd

#starting dnsmasq 
systemctl start dnsmasq

# enable forwarding

sed -i -- 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf

iptables -t nat -A  POSTROUTING -o eth0 -j MASQUERADE # enable forwarding in iptables
sh -c "iptables-save > /etc/iptables.ipv4.nat"  # save the rules 

sed -i -- 's/^exit 0/iptables-restore < \/etc\/iptables.ipv4.nat\n\nexit 0/g' /etc/rc.local # ensure rules are loaded on



##### Setting hostname
hostnamectl set-hostname $hostname

##### restarting services

echo "All done! Please reboot"

