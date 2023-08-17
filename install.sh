#!/bin/bash

git_url=https://github.com/damongolding/james-monitor.git

clear

echo "

  ^...^
(  ̳• · • ̳)
/    づ♡  Hey James!

"
sleep 1
echo -e "
First we need to make sure everything is up to date then we will install some software.
This will take a bit of time
"
sleep 5
echo -n "starting in 3"
sleep 1
echo -n "...2"
sleep 1
echo -e "...1\n"
sleep 1

cd /opt

# Update system
sudo apt -y update
sudo apt -y upgrade


# install things
sudo apt -y remove python3-pil
sudo apt -y install git python3-pip libopenjp2-7

sudo pip install rpi.gpio spidev numpy rich pydantic requests Pillow

echo "

    Cloning repo

"

#  Set up git repo
git clone $git_url
cd james-monitor
git remote add upstream $git_url
sudo chmod +x update.sh


echo "

    Adding tasks

"

# Add cronjob to update
(crontab -l ; echo "0 * * * * /opt/james-monitor/update.sh >/dev/null 2>&1") | crontab -


sudo cat > /lib/systemd/system/monitor.service << EOF
[Unit]
Description=Air monitor
After=network.target
[Service]
ExecStart=/usr/bin/python3 /opt/james-monitor/demo.py
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable monitor
sudo systemctl start monitor


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

