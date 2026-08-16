#!/bin/sh
# ISP2 Secondary Uplink Router (Nexus Global — ISP2 Failover Link)
# Simulates a secondary BGP ISP connection for dual-homed enterprise redundancy

echo "[*] Starting Nexus ISP2 Secondary BGP Router..."

sysctl -w net.ipv4.ip_forward=1

# Flush previous rules
iptables -F
iptables -t nat -F
iptables -X

# NAT Masquerade — simulate ISP2 NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -j ACCEPT

# Static route: ISP2 (203.0.113.0/24) → WAN → HQ BGP Routers
ip route add 10.0.0.0/8 via 203.0.113.2 2>/dev/null || true

echo "[+] ISP2 Router (203.0.113.1) active — Secondary BGP uplink operational."
echo "[+] Simulating: Cogent/NTT AS64512 → Nexus HQ AS65100"

tail -f /dev/null
