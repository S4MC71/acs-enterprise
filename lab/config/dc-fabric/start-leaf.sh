#!/bin/sh
LEAF_ID=${LEAF_ID:-1}
echo "[*] Initializing DC Leaf Switch ${LEAF_ID} (Top-of-Rack / Access Leaf)..."
sysctl -w net.ipv4.ip_forward=1
iptables -F; iptables -t nat -F
iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -j ACCEPT
echo "[+] Leaf-${LEAF_ID} Active | Role: ToR Leaf | VXLAN VNI: 10000${LEAF_ID}"
echo "[+] Connected Servers: VMware ESXi Cluster, PostgreSQL DB, MinIO SAN"
echo "[+] Uplink to Spines: Spine-1 (10.0.3.241), Spine-2 (10.0.3.242)"
echo "[+] Simulating: Arista 7050CX3 Leaf Switch | EOS 4.30"
tail -f /dev/null
