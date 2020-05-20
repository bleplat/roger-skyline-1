#!/usr/bin/env bash

mkdir -p /var/log/

sudo apt update >> /var/log/update_script.log
sudo apt --yes upgrade >> /var/log/update_script.log

