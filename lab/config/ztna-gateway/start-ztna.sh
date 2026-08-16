#!/bin/sh
# Nexus ZTNA / Zero Trust VPN Gateway
# Zone: DMZ (10.0.1.50) | WireGuard Port: 51820

echo "[*] Starting Nexus Zero Trust Network Access Gateway..."
echo "[*] Node: ztna-gw-01.nexus.internal (10.0.1.50)"

sysctl -w net.ipv4.ip_forward=1

iptables -F; iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i wg0 -j ACCEPT

mkdir -p /etc/wireguard

# Generate WireGuard keys (or use fixed for lab reproducibility)
PRIV_KEY="4NexusZTNA+PrivKey/HQ/2026/WireGuard/GW=="
PUB_KEY="4NexusZTNA+PubKey/HQ/2026/WireGuard/GW=="

cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = ${PRIV_KEY}
Address = 10.0.6.1/24
ListenPort = 51820

# Allowed ZTNA clients (pre-provisioned)
[Peer]
# Branch Office SD-WAN (10.0.5.1)
PublicKey = OBranch+PrivKey/NexusDhaka/2026/SD-WAN==
AllowedIPs = 10.0.5.0/24
PresharedKey = SharedPSK+NexusBranch2HQ/SUPERSECRET/2026==

[Peer]
# Remote Worker
PublicKey = RemoteWkr+PubKey/NexusVPN/2026==
AllowedIPs = 10.0.6.10/32
EOF

chmod 600 /etc/wireguard/wg0.conf

echo "[+] WireGuard ZTNA config written to /etc/wireguard/wg0.conf"
echo "[+] ZTNA Policy: Zero Trust — all connections require device cert + user auth"
echo "[+] Tunnel subnet: 10.0.6.0/24 (VPN clients)"
echo "[+] WireGuard listening on UDP/51820"
echo ""
echo "[+] Public Key: ${PUB_KEY}"
echo "[+] For ZTNA bypass lab: see /etc/wireguard/wg0.conf for PSK"

# Start nginx ZTNA portal
nginx -g "daemon off;" &

tail -f /dev/null
