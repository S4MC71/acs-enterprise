#!/bin/sh
# Edge Router Startup Script
# Interfaces: eth0 (WAN 198.51.100.1), eth1 (DMZ 10.0.1.1)

echo "[*] Initializing Edge Gateway Router..."
sysctl -w net.ipv4.ip_forward=1

# Enable NAT for outbound traffic from DMZ to WAN
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# Route traffic for internal subnets via HQ Firewall (10.0.1.254)
ip route add 10.0.2.0/24 via 10.0.1.254 2>/dev/null || true
ip route add 10.0.3.0/24 via 10.0.1.254 2>/dev/null || true
ip route add 10.0.4.0/24 via 10.0.1.254 2>/dev/null || true

echo "[+] Edge Gateway Router is ACTIVE and routing packets."
# Keep container running
tail -f /dev/null
