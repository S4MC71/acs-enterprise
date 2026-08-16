#!/bin/sh
# Nexus Global Enterprise — AWS Transit Gateway / Azure VNet Peering Simulation
# Cloud Zone: 172.16.0.0/24  |  Peering: HQ On-Prem (10.0.0.0/8)

echo "[*] Initializing Cloud Transit Gateway (AWS us-east-1 / Azure East US)..."

sysctl -w net.ipv4.ip_forward=1

iptables -F; iptables -t nat -F
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -j ACCEPT

# Route on-prem traffic into cloud tier
ip route add 10.0.0.0/8 via 172.16.0.254 2>/dev/null || true

echo "[+] Transit Gateway active: Cloud (172.16.0.0/24) ↔ HQ On-Prem (10.0.0.0/8)"
echo "[+] Simulating: AWS Transit Gateway tgw-nexus-prod-us-east-1"
echo "[+] Cloud resources peered:"
echo "    172.16.0.10  Cloud Load Balancer (ALB)"
echo "    172.16.0.20  Kubernetes App Cluster"
echo "    172.16.0.30  Cloud Managed DB (RDS)"
echo "    172.16.0.40  SaaS SSO Portal"

tail -f /dev/null
