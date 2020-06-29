#!/usr/bin/env sh

SERVICES=$(systemctl list-unit-files | grep enabled | sed "s/^\(.*\)service//" | sed "s/[[:space:]]*$//")
REQUIERED="autovt@.service getty@.service networking.service ssh.service sshd.service syslog.service rsyslog.service cron.service fail2ban.service"

echo "$SERVICES" | while IFS= read -r line ; do
	if [[ $REQUIERED == *"$line"* ]]; then
		echo "keeping $line enabled"
	else
		echo "disabling $line"
		sudo systemctl disable "$line"
	fi
done
