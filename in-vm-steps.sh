#!/usr/bin/env bash

# Prompt confirmation
read -p "This script requieres that you installed the machine the right way, press ENTER if you did so, otherwise, read the comments in the script." garbage

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

# Partitioning method: Manual
# sda:
#  create empty partition table: yes
#  FREE SPACE -> 4.501 GB (4.2 Go) -> mount /
#  FREE SPACE -> 1 GB (I dont care) -> swap
#  FREE SPACE -> mount /home

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

read -p "Press ENTER to update the machine." garbage
./update.sh


# Install requiered packages

read -p "Press ENTER to install requiered packages." garbage
sudo apt --yes install git
sudo apt --yes install sendmail mailutils
sudo apt --yes install ssh


# Override Network Interfaces

read -p "Press ENTER to install requiered network interfaces." garbage
sudo cp ./interfaces /etc/network/interfaces
sudo systemctl restart networking
sudo ifup enp0s3
sudo ifup enp0s8


# Setup SSH Port

read -p "Press ENTER to authorize the demo public key." garbage
mkdir -p /home/user/.ssh/
cat user.pub >> /home/user/.ssh/authorized_keys

read -p "Press ENTER to setup custom sshd config." garbage
sshd_config="/etc/ssh/sshd_config"
#sshd_config=$(find / -name "sshd_config" 1>/dev/null)
sudo cp ./sshd_config $sshd_config
sudo systemctl restart sshd
echo "connect with \`ssh -i ./user -p 8822 user@192.168.56.2\`"


# Custom iptables

read -p "Press ENTER to setup firewall." garbage
sudo cp setup_iptables.sh /opt/
sudo chown root:root /opt/setup_iptables.sh
sudo chmod 700 /opt/setup_iptables.sh
if grep -q "^# SETUP IPTABLES$" "/etc/crontab"; then
	echo auto update is already enabled
else
	sudo echo "# SETUP IPTABLES" >> /etc/crontab
	sudo echo "@reboot      root  sh /opt/setup_iptables.sh > /dev/null 2>&1" >> /etc/crontab
fi


# Fail to ban

read -p "Press ENTER to setup fail2ban." garbage
sudo apt --yes install fail2ban
sudo cp jail.local /etc/fail2ban/jail.local
sudo service fail2ban restart
#sudo fail2ban-client status


# Portsentry

read -p "Press ENTER to setup portsentry." garbage
sudo apt --yes install portsentry
sudo cp portsentry.conf /etc/portsentry/portsentry.conf
sudo service portsentry restart


# Auto update

read -p "Press ENTER to setup auto update" garbage
sudo cp update.sh /opt/
sudo chown root:root /opt/update.sh
sudo chmod 700 /opt/update.sh
if grep -q "^# AUTO UPDATE$" "/etc/crontab"; then
	echo auto update is already enabled
else
	sudo echo "# AUTO UPDATE" >> /etc/crontab
	sudo echo "0 4   * * 1  root  sh /opt/update.sh" >> /etc/crontab
	sudo echo "@reboot      root  sh /opt/update.sh" >> /etc/crontab
fi


# Monitor crontab edits

read -p "Press ENTER to setup cron edits monitoring" garbage
sudo cp check_crontab.sh /opt/
sudo chown root:root /opt/check_crontab.sh
sudo chmod 700 /opt/check_crontab.sh
if grep -q "^# CRONTAB MONITORING$" "/etc/crontab"; then
	echo crontab is already being monitored
else
	sudo echo "# CRONTAB MONITORING" >> /etc/crontab
	sudo echo "0 0   * * *  root  sh /opt/check_crontab.sh" >> /etc/crontab
fi
if grep -q "^127.0.0.1.localhost localhost.localdomain RS1" "/etc/hosts"; then
	echo "not touching /etc/hosts"
else
	sudo cp /etc/hosts ./hosts
	sudo echo "127.0.0.1 localhost localhost.localdomain RS1" > /etc/hosts
	sudo cat ./hosts >> /etc/hosts
	sudo rm ./hosts
fi


# Disable services

sudo sh disable_services.sh

