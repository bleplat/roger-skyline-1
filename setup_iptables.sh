#!/usr/bin/env bash

echo Flushing iptables...
iptables -F
iptables -F INPUT
iptables -F OUTPUT
iptables -F FORWARD

echo Setting up iptables: Accept established connections
iptables -t filter -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -t filter -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

echo Setting up iptables: Accept loopback
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

echo Setting up iptables: Drop attacks: private ranges
echo Warning: For internal networks, remove lines about your ip
# SPOOFING (private ranges)
iptables -t mangle -A PREROUTING -s 10.0.0.0/8 ! -i lo -j DROP 
iptables -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP
iptables -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP
iptables -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP
iptables -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP
#iptables -t mangle -A PREROUTING -s 192.168.0.0/16 ! -i lo -j DROP
# SPOOFING (reserved ranges)
iptables -t mangle -A PREROUTING -s 0.0.0.0/8 ! -i lo -j DROP
iptables -t mangle -A PREROUTING -d 0.0.0.0/8 ! -i lo -j DROP
iptables -t mangle -A PREROUTING -s 224.0.0.0/4 -j DROP
iptables -t mangle -A PREROUTING -d 224.0.0.0/4 -j DROP
iptables -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP
iptables -t mangle -A PREROUTING -d 240.0.0.0/5 -j DROP
iptables -t mangle -A PREROUTING -d 239.255.255.0/24 -j DROP
iptables -t mangle -A PREROUTING -d 255.255.255.255 -j DROP

echo Setting up iptables: Drop attacks: other
# SMURF
iptables -A INPUT -p icmp -m icmp --icmp-type address-mask-request -j DROP
iptables -A INPUT -p icmp -m icmp --icmp-type timestamp-request -j DROP
iptables -A INPUT -p icmp -m limit --limit 1/second -j ACCEPT
iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT
# SYN FLOOD (requiere SYN + disallow uncommon TCP MSS)
iptables -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP
iptables -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! -mss 536:65535 -j DROP
# NEW TCP CONNECTION FLOOD
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 20/s --limit-burst 20 -j ACCEPT 
iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
# UNLEGITIMATE TCP FLAGS (short list)
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
# UDP FRAGMENTED (may block legitimate)
#iptables -t mangle -A PREROUTING -f -j DROP

echo Setting up iptables: Drop invalid
iptables -A INPUT -m state --state INVALID -j DROP
iptables -A FORWARD -m state --state INVALID -j DROP
iptables -A OUTPUT -m state --state INVALID -j DROP

echo Setting up iptables: Limit connections
iptables -A INPUT -p tcp -m connlimit --connlimit-above 80 -j REJECT --reject-with tcp-reset
iptables -A INPUT -p udp -m connlimit --connlimit-above 40 -j DROP

echo Setting up iptables: Block Portscan
# Block attackers 1 day (3600*24)
iptables -A INPUT -m recent --name portscan --rcheck --seconds 86400
iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400
iptables -A INPUT -m recent --name portscan --remove
iptables -A FORWARD -m recent --name portscan --remove
iptables -A INPUT -p udp -m multiport --dports 21,22,23,25,139,443,7776,17776,27776 -m recent --name portscan --set -j LOG --log-prefix "PORTSCAN:"
iptables -A INPUT -p tcp -m multiport --dports 21,22,23,25,139,443,7776,17776,27776 -m recent --name portscan --set -j LOG --log-prefix "PORTSCAN:"
iptables -A FORWARD -p tcp -m multiport --dports 21,22,23,25,139,443,7776,17776,27776 -m recent --name portscan --set -j DROP
iptables -A FORWARD -p udp -m multiport --dports 21,22,23,25,139,443,7776,17776,27776 -m recent --name portscan --set -j DROP

# PrtTrap chain
#iptables -N PortTrap
#iptables -A PortTrap ! -i lo -m recent --rcheck --name portscanners --rsource -j DROP
#iptables -A PortTrap ! -i lo -p tcp -m multiport --dports {21,22,23,25,443,7776,17776,27776,8821} -m tcp -m recent --set --name portscanners --rsource -j DROP
#iptables -A PortTrap ! -i lo -p udp -m multiport --dports {21,22,23,25,443,7776,17776,27776,8821} -m udp -m recent --set --name portscanners --rsource -j DROP
#iptables -A PortTrap -j RETURN
#iptables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -j PortTrap

echo Setting up iptables: Drop PING
iptables -t mangle -A PREROUTING -p icmp -j DROP

#echo Setting up iptables: Accept DNS
#iptables -t filter -A INPUT -p tcp --dport 53 -j ACCEPT
#iptables -t filter -A INPUT -p udp --dport 53 -j ACCEPT
#iptables -t filter -A OUTPUT -p tcp --dport 53 -j ACCEPT
#iptables -t filter -A OUTPUT -p udp --dport 53 -j ACCEPT


echo Setting up iptables: Default policies
iptables -A INPUT -j DROP
iptables -P INPUT DROP
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

