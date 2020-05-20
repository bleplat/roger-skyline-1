#!/usr/bin/env bash

sudo mkdir -p /var/log/ > /dev/null

sudo apt update >> /var/log/update_script.log 2>&1
sudo apt --yes upgrade >> /var/log/update_script.log 2>&1

