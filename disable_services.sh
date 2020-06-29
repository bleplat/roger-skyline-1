#!/usr/bin/env bash

REQUIERED="autovt@.service getty@.service networking.service ssh.service sshd.service syslog.service rsyslog.service cron.service fail2ban.service"


# Disable kind services

SERVICES=$(systemctl list-unit-files | grep enabled | sed "s/^\(.*\)enabled.*$/\1/" | sed "s/[[:space:]]*$//")

echo "$SERVICES" | while IFS= read -r line ; do
	if [[ $REQUIERED == *"$line"* ]]; then
		echo "keeping $line enabled"
	else
		echo "disabling $line"
		sudo systemctl --now disable "$line"
	fi
done


# That's what you got

SERVICES=$(systemctl list-unit-files | grep enabled | sed "s/^\(.*\)enabled.*$/\1/" | sed "s/[[:space:]]*$//")

echo "$SERVICES" | while IFS= read -r line ; do
	if [[ $REQUIERED == *"$line"* ]]; then
		echo "keeping $line enabled" > /dev/null
	else
		echo "exterminating heretics $line"
		sudo systemctl --now mask "$line"
	fi
done




