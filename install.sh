#!/bin/bash

git_url=https://github.com/damongolding/james-monitor.git

clear

echo "Hey James!"
sleep 3
echo -e "\nFirst we need to make sure everything is up to date then we will install some software\n"
sleep 5
echo -n "starting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1

cd ~

# Update system
sudo apt -y update
sudo apt -y upgrade


# install things
sudo apt -y install git python3-rpi.gpio python3-spidev python3-pip python3-pil python3-numpy python3-rich python3-pydantic python3-requests

#  Set up git repo
git clone $git_url
cd james
git remote add upstream $git_url

# Make update script executable
chmod a+rx update.sh

# Add cronjob to update
(crontab -l ; echo "0 * * * * ~/james/update.sh >/dev/null 2>&1") | crontab -
(crontab -l ; echo "@reboot python3 ~/james-monitor/monitor.py >/dev/null 2>&1") | crontab -


# Enable harware for monitor
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_spi 0

python3 tests.py

sleep 5
clear
echo -n "Rebooting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1

sudo reboot now

