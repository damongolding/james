#!/bin/bash

git_url=https://github.com/damongolding/james-monitor.git
current_user=$(whoami)

clear

echo "

  ^...^
(  ̳• · • ̳)
/    づ♡  Hey James!

"
sleep 1
echo -e "\nFirst we need to make sure everything is up to date then we will install some software\n"
sleep 5
echo -n "starting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1

cd /home/$current_user

# Update system
# sudo apt -y update
# sudo apt -y upgrade


# # install things
# sudo apt -y install git python3-pip libopenjp2-7

# sudo pip install rpi.gpio spidev numpy rich pydantic requests

echo "

    Cloning repo

"

#  Set up git repo
git clone $git_url
cd james-monitor
git remote add upstream $git_url

# Make update script executable
sudo chmod a+rx update.sh

echo "

    Adding tasks

"

# Add cronjob to update
(crontab -l ; echo "0 * * * * /home/james-monitor/update.sh >/dev/null 2>&1") | crontab -

sudo touch /lib/systemd/system/monitor.service
sudo echo "
[Unit]
Description=Air monitor
[Service]
Type=simple
Restart=always
ExecStart=/usr/bin/python3 /home/$current_user/james-monitor/demo.py
[Install]
WantedBy=multi-user.target
" >> /lib/systemd/system/monitor.service

sudo systemctl start monitor
sudo systemctl enable monitor


# Enable harware for monitor
sudo raspi-config nonint do_i2c 0
sudo raspi-config nonint do_spi 0

# python3 tests.py
echo ""

# draw a cat
while IFS= read -r line
do
  echo "$line"
  sleep 0.05
done < "cat_ansi"

sleep 5
echo ""
echo -n "Rebooting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1

sudo reboot now

