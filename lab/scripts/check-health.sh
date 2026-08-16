#!/bin/bash
# Nexus Enterprise Lab Health Check Script - Linux/macOS

echo -e "\033[1;36m============================================================\033[0m"
echo -e "\033[1;33m 🔍 Checking Nexus Enterprise Lab Container Status...\033[0m"
echo -e "\033[1;36m============================================================\033[0m"

CONTAINERS=(
    "nexus-attacker-box"
    "nexus-edge-router"
    "nexus-hq-firewall"
    "nexus-corp-waf-proxy"
    "nexus-corp-web-portal"
    "nexus-corp-mail-server"
    "nexus-ad-dc"
    "nexus-dc-prod-database"
    "nexus-dc-internal-erp"
    "nexus-dc-backup-storage"
    "nexus-pc-dev-01"
    "nexus-pc-hr-01"
)

ALL_RUNNING=true

for c in "${CONTAINERS[@]}"; do
    STATUS=$(docker inspect -f '{{.State.Status}}' "$c" 2>/dev/null)
    if [ "$STATUS" = "running" ]; then
        echo -e " \033[1;32m[✓] $c is RUNNING\033[0m"
    else
        echo -e " \033[1;31m[✗] $c is NOT running ($STATUS)\033[0m"
        ALL_RUNNING=false
    fi
done

echo ""
if [ "$ALL_RUNNING" = true ]; then
    echo -e "\033[1;32m[+] All 12 Enterprise Nodes are Healthy and Online!\033[0m"
else
    echo -e "\033[1;31m[-] Some containers failed to start. Run 'docker compose logs' for details.\033[0m"
fi
