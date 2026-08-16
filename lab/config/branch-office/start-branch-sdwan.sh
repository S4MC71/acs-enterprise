#!/bin/sh
# Nexus Global Enterprise — Branch Office SD-WAN Edge Router
# Branch: Dhaka Regional Office | Subnet: 10.0.5.0/24
# WireGuard VPN Tunnel to HQ ZTNA Gateway (10.0.1.50)

echo "[*] Initializing Branch Office SD-WAN Edge (Dhaka Regional HQ)..."
echo "[*] Branch: nexus-dhaka-branch.nexus.internal"

sysctl -w net.ipv4.ip_forward=1

iptables -F; iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -j ACCEPT

# Branch LAN routes
ip route add 10.0.0.0/8 via 10.0.5.254 2>/dev/null || true

echo "[+] Branch SD-WAN Active. Topology:"
echo "    Branch LAN:   10.0.5.0/24"
echo "    HQ Tunnel:    10.0.1.50 (ZTNA Gateway)"
echo "    WireGuard:    Port 51820/UDP"
echo ""
echo "[+] Simulating: Viptela SD-WAN Branch Edge (vEdge)"
echo "[!] WireGuard tunnel: Pre-shared key stored in /etc/wireguard/wg0.conf"
echo "    (intentionally world-readable for lab — check permissions!)"

# Create insecure WireGuard config (readable by all — intentional for lab)
mkdir -p /etc/wireguard
cat > /etc/wireguard/wg0.conf << 'WGCONF'
[Interface]
PrivateKey = OBranch+PrivKey/NexusDhaka/2026/SD-WAN==
Address = 10.0.5.1/24
ListenPort = 51820

[Peer]
# HQ ZTNA Gateway (10.0.1.50)
PublicKey = HQZTNA+PubKey/NexusHQ/2026/ZTNA==
Endpoint = 10.0.1.50:51820
AllowedIPs = 10.0.0.0/8
PresharedKey = SharedPSK+NexusBranch2HQ/SUPERSECRET/2026==
PersistentKeepalive = 25
WGCONF

chmod 644 /etc/wireguard/wg0.conf   # Intentionally insecure permissions

echo "[!] WARNING: /etc/wireguard/wg0.conf is world-readable (misconfiguration)"

tail -f /dev/null
