#!/bin/bash

MACHINE=$1
if [ -z "$MACHINE" ] ; then
  printf "\e[31mYOU NEED TO ENTER A MACHINE NAME\e[0m"
  exit 1
fi
TIMEOUT=$2
if [ -z "$TIMEOUT" ] ; then
  printf "\e[31mYOU NEED TO ENTER TIMEOUT\e[0m"
  exit 1
fi

printf "\e[92mWaiting for $MACHINE to exit...\e[0m"
VBoxManage controlvm $MACHINE acpipowerbutton

until [ -z "$(VBoxManage list runningvms | grep $MACHINE)" ]
do
  if [ $TIMEOUT -lt 1 ] ; then
    printf "\e[91mStopping $MACHINE by force!\e[0m"
    VBoxManage controlvm $MACHINE poweroff
    exit 0
  fi
  TIMEOUT=$((TIMEOUT-1))
  sleep 1
done

exit 0
