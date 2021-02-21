#!/bin/sh

[ "$IFACE" != "lo" ] || exit 0

input="INPUT-CUSTOM"

############################  CLEAN
iptables -F 
iptables -X
ip6tables -F 
ip6tables -X


############################  INIT
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
iptables -N $input
iptables -N DOCKER-USER
iptables -A INPUT -j $input

ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT
ip6tables -N $input
ip6tables -A INPUT -j $input

iptables -F $input
iptables -F DOCKER-USER
ip6tables -F $input

############################ CUSTOM RULES
iptables -A $input -i lo -j ACCEPT -m comment --comment "Accept loopback traffic"
ip6tables -A $input -i lo -j ACCEPT -m comment --comment "Accept loopback traffic"

## PING
#iptables -A $input -p icmp -m icmp --icmp-type echo-request -j ACCEPT -m comment --comment "Accept pings"

## SSH Connections
#iptables -A $input -p tcp --dport 22 -j ACCEPT -m comment --comment "Accept SSH"

iptables -A $input -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Accept established, related"
ip6tables -A $input -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -m comment --comment "Accept established, related traffic"


############################ DEFAULT CODE : RETURN
iptables -A $input -j RETURN
iptables -A DOCKER-USER -j RETURN
ip6tables -A $input -j RETURN
