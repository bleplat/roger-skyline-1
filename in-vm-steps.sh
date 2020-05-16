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


