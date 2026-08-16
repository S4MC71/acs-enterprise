#!/bin/sh
# Next-Gen Enterprise Perimeter Firewall (HQ-FW-01)
# Interfaces:
# eth0 (DMZ: 10.0.1.254)
# eth1 (Core: 10.0.2.1)
# eth2 (DC: 10.0.3.1)
# eth3 (Campus: 10.0.4.1)

echo "[*] Configuring Enterprise Next-Gen Firewall (HQ-FW-01)..."
sysctl -w net.ipv4.ip_forward=1

# Flush old rules
iptables -F
iptables -t nat -F
iptables -X

# Set Default Policy
iptables -P INPUT ACCEPT
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# 1. Allow Established and Related connections across all zones
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

# 2. Allow ICMP (Ping) for internal diagnostics
iptables -A FORWARD -p icmp -j ACCEPT

# 3. DMZ to Core Rules:
# DMZ Web / Bastion can reach Active Directory (10.0.2.10) for DNS/LDAP authentication
iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.2.10 -p tcp -m multiport --dports 53,88,389,636 -j ACCEPT
iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.2.10 -p udp -m multiport --dports 53,88 -j ACCEPT
# DMZ can send Syslog to SIEM (10.0.2.99)
iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.2.99 -p udp --dport 514 -j ACCEPT

# 4. DMZ to Data Center (DC):
# DIRECT access from DMZ to DC DB (5432) or SAN (9000) is STRICTLY BLOCKED!
# Only if DMZ web app is configured to query internal DC ERP (8000)
iptables -A FORWARD -s 10.0.1.20 -d 10.0.3.10 -p tcp --dport 8000 -j ACCEPT
iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.3.0/24 -j DROP

# 5. Campus Workstations (10.0.4.0/24) Rules:
# Workstations can reach Core AD (10.0.2.10) on SMB/Kerberos/LDAP/DNS
iptables -A FORWARD -s 10.0.4.0/24 -d 10.0.2.10 -p tcp -m multiport --dports 53,88,135,139,389,445,636 -j ACCEPT
iptables -A FORWARD -s 10.0.4.0/24 -d 10.0.2.10 -p udp -m multiport --dports 53,88,389 -j ACCEPT
# Workstations can access DC Intranet ERP (10.0.3.10:8000)
iptables -A FORWARD -s 10.0.4.0/24 -d 10.0.3.10 -p tcp --dport 8000 -j ACCEPT
# Workstations can access Backup SAN Web UI / MinIO (10.0.3.30:9000, 9001)
iptables -A FORWARD -s 10.0.4.0/24 -d 10.0.3.30 -p tcp -m multiport --dports 9000,9001 -j ACCEPT
# DevOps PC (10.0.4.20) has SSH access to Data Center DB (10.0.3.20)
iptables -A FORWARD -s 10.0.4.20 -d 10.0.3.20 -p tcp -m multiport --dports 22,5432 -j ACCEPT

# 6. Core Subnet (10.0.2.0/24) to DC:
# AD DC & SIEM can communicate with DC services
iptables -A FORWARD -s 10.0.2.0/24 -d 10.0.3.0/24 -j ACCEPT

# 7. Logging dropped unauthorized packets for SIEM analysis
iptables -A FORWARD -m limit --limit 5/min -j LOG --log-prefix "[HQ-FW-BLOCKED]: " --log-level 7

echo "[+] Enterprise Next-Gen Firewall (HQ-FW-01) is ACTIVE with stateful filtering."
tail -f /dev/null
