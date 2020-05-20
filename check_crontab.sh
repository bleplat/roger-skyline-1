#!/usr/bin/env bash

chasum /etc/crontab >> crontab_shasum.new

if cmp -s "crontab_shasum.old" "crontab_shasum.new"; then
	echo "crontab didnt change" > /dev/null
else
	echo "crontab changed!" | mail -s "crontab changed" root@127.0.0.1
fi

mv crontab_shasum.new crontab_shasum.old

