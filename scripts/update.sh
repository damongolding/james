#!/bin/bash
cd /opt/james-monitor

sudo git fetch upstream
message=$(sudo git merge upstream/main)


if [ "$message" = "Already up to date." ]; then
    exit 0
else
    sudo systemctl restart monitor
    sudo systemctl restart monitor-frontend
fi
