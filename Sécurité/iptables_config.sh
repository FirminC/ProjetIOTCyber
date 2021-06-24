#!/bin/bash 

if [[ "${UID}" -ne 0 ]]; then
  echo "Please execute this script with root privileges." >&2
  exit 1
fi

INTERFACE="wlp3s0"
SERVER_IP="$(ip addr show wlp3s0 | grep 'inet ' | cut -f2 | awk '{ print $2}')"


# Create a new chain to log and drop rejected packets
iptables --new-chain LOG_AND_DROP
iptables -A LOG_AND_DROP --match limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
iptables -A LOG_AND_DROP -j DROP

# Drop null and XMAS (all TCP flags on) packets (may prevent some attacks)
iptables -A INPUT -i "$INTERFACE" --protocol tcp --tcp-flags ALL NONE -j LOG_AND_DROP
iptables -A INPUT -i "$INTERFACE" --protocol tcp --tcp-flags ALL ALL -j LOG_AND_DROP

# Drop all fragmented packets (-f = fragments)
iptables -A INPUT -i "$INTERFACE" --fragment -j LOG_AND_DROP

# Make sure all TCP connections start with a SYN packet
# Drop all SYN packets that doesn't initiate a connection
iptables -A INPUT -i "$INTERFACE" --protocol tcp ! --syn --match state --state NEW -j LOG_AND_DROP

# Drop all invalid packets
iptables -A INPUT -i "$INTERFACE" --match state --state INVALID -j LOG_AND_DROP
iptables -A FORWARD -i "$INTERFACE" --match state --state INVALID -j LOG_AND_DROP
iptables -A OUTPUT -o "$INTERFACE" --match state --state INVALID -j LOG_AND_DROP

# Accept any already established connections
iptables -A INPUT -i "$INTERFACE" --match state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o "$INTERFACE" --match state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback access
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow DNS resolution

iptables -A INPUT --protocol udp --sport 53 --destination $SERVER_IP --dport 1024:65535 --match state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT --protocol tcp --sport 53 --destination $SERVER_IP --dport 1024:65535 --match state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT --protocol udp --source $SERVER_IP --sport 1024:65535 --dport 53 --match state --state NEW,ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT --protocol tcp --source $SERVER_IP --sport 1024:65535 --dport 53 --match state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Allow ALL incoming SSH (port 22) with a limit of 25 new connection per minute after 100 established connections (prevent DoS attack)
iptables -A INPUT -i "$INTERFACE" --protocol tcp --source 0/0 --sport 1024:65535 --destination $SERVER_IP --dport 25565 --match state --state NEW,ESTABLISHED,RELATED --match limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A OUTPUT -o "$INTERFACE" --protocol tcp --source $SERVER_IP --sport 25565 --destination 0/0 --dport 1024:65535 --match state --state ESTABLISHED,RELATED -j ACCEPT

# Allow incoming HTTP (port 80) with a limit of 25 new connection per minute after 100 established connections (prevent DoS attack)
iptables -A INPUT -i "$INTERFACE" --protocol tcp --source 0/0 --sport 1024:65535 --destination $SERVER_IP --dport 80 --match state --state NEW,ESTABLISHED,RELATED --match limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A OUTPUT -o "$INTERFACE" --protocol tcp --source $SERVER_IP --sport 80 --destination 0/0 --dport 1024:65535  --match state --state ESTABLISHED,RELATED -j ACCEPT

# Allow incoming HTTPS (port 443) with a limit of 25 new connection per minute after 100 established connections (prevent DoS attack)
iptables -A INPUT -i "$INTERFACE" --protocol tcp --source 0/0 --sport 1024:65535 --destination $SERVER_IP --dport 443 --match state --state NEW,ESTABLISHED,RELATED --match limit --limit 25/minute --limit-burst 100 -j ACCEPT
iptables -A OUTPUT -o "$INTERFACE" --protocol tcp --source $SERVER_IP --sport 443 --destination 0/0 --dport 1024:65535 --match state --state ESTABLISHED,RELATED -j ACCEPT

# Allow incoming FTP (port 21 and passive ports 21100:21110) with a limit of 25 new connection per minute after 100 established connections (prevent DoS attack)
#iptables -A INPUT -i "$INTERFACE" --protocol tcp --source 0/0 --sport 1024:65535 --destination $SERVER_IP --dport 21 --match state --state NEW,ESTABLISHED,RELATED --match limit --limit 25/minute --limit-burst 100 -j ACCEPT
#iptables -A OUTPUT -o "$INTERFACE" --protocol tcp --source $SERVER_IP --sport 21 --destination 0/0 --dport 1024:65535 --match state --state ESTABLISHED,RELATED -j ACCEPT
#
#iptables -A INPUT -i "$INTERFACE" --protocol tcp --source 0/0 --sport 21100:21110 --destination $SERVER_IP --dport 21100:21110 --match state --state NEW,ESTABLISHED,RELATED --match limit --limit 25/minute --limit-burst 100 -j ACCEPT
#iptables -A OUTPUT -o "$INTERFACE" --protocol tcp --source $SERVER_IP --sport 21100:21110 --destination 0/0 --dport 21100:21110 --match state --state ESTABLISHED,RELATED -j ACCEPT

# Disallow ICMP request from outside
#iptables -A INPUT -i "$INTERFACE" --protocol icmp --icmp-type echo-request --match state --state NEW,ESTABLISHED,RELATED -j LOG_AND_DROP
#iptables -A OUTPUT -o "$INTERFACE" --protocol icmp --icmp-type echo-reply --match state --state ESTABLISHED,RELATED -j LOG_AND_DROP

# Allow ICMP request to distant hosts
iptables -A INPUT -i "$INTERFACE" --protocol icmp --icmp-type echo-reply --match state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o "$INTERFACE" --protocol icmp --icmp-type echo-request --match state --state NEW,ESTABLISHED,RELATED -j ACCEPT

# Drop all other packets by default
iptables -A INPUT -i "$INTERFACE" -j LOG_AND_DROP
iptables -A FORWARD -i "$INTERFACE" -j LOG_AND_DROP
iptables -A OUTPUT -o "$INTERFACE" -j LOG_AND_DROP
