#!/usr/bin/env bash

# Prompt confirmation
read -p "This script requieres that you installed the machine the right way, press ENTER if you did so, otherwise, read the comments in the script."

###########################
# MACHINE BEING INSTALLED #
###########################

# Language: English
# Country: France
# Locale: United States
# Keymap: French

# Primary net interface: enp0s3  
# Hostname: RS1
# Domain:

# Root password:
# New user name: user
# User name: user
# New user passwor: 1234abcdE

# Partitioning method: manual
# sda:
#  create empty partition table: yes
#  FREE SPACE -> 4.41 GB (4.2 Go) -> mount /
#  FREE SPACE -> mount swap

# Scan another CD: no
# Debian archive mirror: deb.debian.org
# only select standar utilities
# Install grub: yes: sda


##########################
# RUN INSIDE THE MACHINE #
##########################

# cd
# sudo apt update && sudo apt --yes install git
# git clone https://github.com/bleplat/roger-skyline-1.git
# cd roger-skyline-1
# sudo sh in-vm-steps.sh

# Update the machine

read -p "Press ENTER to update the machine."
./update.sh


# Install requiered packages

read -p "Press ENTER to install requiered packages."
sudo apt --yes install git
echo "Answer Local only and RS1:"
sudo apt --yes install postfix
sudo apt --yes install ssh


# Override Network Interfaces

read -p "Press ENTER to install requiered network interfaces."
sudo cp ./interfaces /etc/network/interfaces
sudo systemctl restart networking
sudo ifup enp0s3
sudo ifup enp0s8

# Setup SSH Port

read -p "Press ENTER to authorize the demo public key."
mkdir -p /home/user/.ssh/
cat user.pub >> /home/user/.ssh/authorized_keys

read -p "Press ENTER to setup custom sshd config."
sshd_config="/etc/ssh/sshd_config"
#sshd_config=$(find / -name "sshd_config" 1>/dev/null)
sudo cp ./sshd_config $sshd_config
sudo systemctl restart sshd
echo "connect with \`ssh -i ./user -p 8822 user@192.168.56.2\`"


# Auto update

read -p "Press ENTER to setup auto update"
if grep -q "^# AUTO UPDATE$" "/etc/crontab"; then
	echo auto update is already enabled
else
	sudo cp update.sh /opt/
	sudo chown root:root /opt/update.sh
	sudo chmod 700 /opt/update.sh
	sudo echo "# AUTO UPDATE" >> /etc/crontab
	sudo echo "0 4   * * 1  root  /opt/update" >> /etc/crontab
	sudo echo "@reboot      root  /opt/update" >> /etc/crontab
	crontab -e
fi


# Monitor crontab edits

read -p "Press ENTER to setup cron edits monitoring"
if grep -q "^# CRONTAB MONITORING$" "/etc/crontab"; then
	echo crontab is already being monitored
else
	sudo cp check_cron.sh /opt/
	sudo chown root:root /opt/check_cron.sh
	sudo chmod 700 /opt/check_cron.sh
	sudo echo "# CRONTAB MONITORING" >> /etc/crontab
	sudo echo "0 0   * * *  root  /opt/update" >> /etc/crontab
	crontab -e
fi


