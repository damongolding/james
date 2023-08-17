#!/bin/bash
cd /opt/james-monitor

sudo git fetch upstream
message=$(sudo git merge upstream/main)

date >> date.txt

if [ "$message" = "Already up to date." ]; then
    exit 0
else
    sudo systemctl restart monitor
fi
