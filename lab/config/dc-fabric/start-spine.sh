#!/bin/sh
# Nexus Data Center Spine Switch — Simulates Cisco Nexus 9000 / Arista 7500 Spine
SPINE_ID=${SPINE_ID:-1}
echo "[*] Initializing DC Spine Switch ${SPINE_ID} (Nexus 9516 Spine Layer)..."
sysctl -w net.ipv4.ip_forward=1
iptables -F; iptables -t nat -F
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -j ACCEPT

echo "[+] Spine-${SPINE_ID} Active | Role: L3 BGP Spine | DC Fabric Interconnect"
echo "[+] Connected Leaf switches: Leaf-1 (10.0.3.243), Leaf-2 (10.0.3.244)"
echo "[+] Uplink to Core: Core-Switch-A (10.0.2.1)"
echo "[+] BGP AS: 65200 (DC Fabric) | Protocol: BGP-EVPN over VXLAN"
echo "[+] Simulating: Cisco Nexus 9516 | NX-OS 10.3"
tail -f /dev/null
