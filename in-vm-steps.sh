#!/usr/bin/env bash

# Prompt confirmation
read -p "This script requieres that you installed the machine the right way, press ENTER if you did so, otherwise, read the comments in the script."

###########################
# MACHINE BEING INSTALLED #
###########################


#
#  
#  



##########################
# RUN INSIDE THE MACHINE #
##########################


# Update the machine

read -p "Press ENTER to update the machine."
./update.sh


# Install requiered packages

read -p "Press ENTER to install requiered packages."
sudo apt --yes install git
sudo apt --yes install postfix


# Override Network Interfaces

read -p "Press ENTER to install requiered network interfaces."
sudo cp ./interfaces /etc/network/interfaces
sudo systemctl restart networking


# Setup SSH Port

read -p "Press ENTER to authorize the demo public key."
mkdir -p /home/user/.ssh/
cat user.pub > /home/user/.ssh/authorized_keys

read -p "Press ENTER to setup custom sshd config."
sshd_config="/etc/ssh/sshd_config"
#sshd_config=$(find / -name "sshd_config" 1>/dev/null)
sudo cp ./sshd_config $sshd_config
sudo systemctl restart sshd.service


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


