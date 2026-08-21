#!/bin/bash
# ============================================================
#  Nexus Enterprise Lab - Health Check Script (Linux/macOS)
#  Usage: ./check-health.sh [auto|core|enterprise|all]
# ============================================================

MODE="${1:-auto}"

# 0. Check Docker availability
if ! command -v docker &> /dev/null; then
    echo -e "[1;31m[!] Docker is not installed or not in PATH![0m"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "[1;31m[!] Docker daemon is not running![0m"
    exit 1
fi

CORE_CONTAINERS=(
    "nexus-edge-router:[WAN]:Edge Router (BGP-A / ISP1)"
    "nexus-hq-firewall:[NGFW]:Perimeter Firewall"
    "nexus-corp-waf-proxy:[DMZ]:Nginx WAF / Reverse Proxy"
    "nexus-corp-web-portal:[DMZ]:Corporate Web Portal (Flask)"
    "nexus-corp-mail-server:[DMZ]:Mail Server (MailHog)"
    "nexus-corp-bastion:[DMZ]:SSH Bastion Jump Host"
    "nexus-ad-dc:[Core]:Active Directory DC (Samba)"
    "nexus-corp-siem-soc:[Core]:SIEM Syslog Collector"
    "nexus-dc-prod-database:[DC]:PostgreSQL DB (Crown Jewels)"
    "nexus-dc-internal-erp:[DC]:Internal ERP Intranet"
    "nexus-dc-backup-storage:[DC]:MinIO SAN Storage"
    "nexus-pc-dev-01:[Campus]:DevOps Workstation (tahmed)"
    "nexus-pc-hr-01:[Campus]:HR Workstation (sjenkins)"
)

ENTERPRISE_CONTAINERS=(
    "nexus-isp2-router:[WAN]:ISP2 Router (BGP-B Secondary)"
    "nexus-ddos-proxy:[WAN]:DDoS Protection Proxy"
    "nexus-ztna-gateway:[DMZ]:ZTNA / Zero Trust VPN GW"
    "nexus-nac-server:[Core]:NAC ISE (802.1X Simulation)"
    "nexus-nms-prometheus:[Core]:NMS Prometheus Scraper"
    "nexus-nms-grafana:[Core]:NMS Grafana Dashboard"
    "nexus-dc-spine-1:[DC]:DC Spine Switch 1 (BGP)"
    "nexus-dc-spine-2:[DC]:DC Spine Switch 2 (BGP)"
    "nexus-dc-leaf-1:[DC]:DC Leaf Switch 1 (ToR)"
    "nexus-dc-leaf-2:[DC]:DC Leaf Switch 2 (ToR)"
    "nexus-dc-backup-dr:[DC]:DR Backup Storage (MinIO)"
    "nexus-branch-sdwan:[Branch]:Branch SD-WAN Edge (Dhaka)"
    "nexus-branch-pc-01:[Branch]:Branch Employee PC (ibrahim)"
    "nexus-voip-pbx:[Campus]:VoIP PBX Asterisk (SIP)"
    "nexus-iot-device-01:[Campus]:IoT MQTT Sensor (Broker)"
    "nexus-ipcam-server:[Campus]:IP Camera RTSP Server"
)

CLOUD_CONTAINERS=(
    "nexus-cloud-gateway:[Cloud]:Transit Gateway (AWS TGW sim)"
    "nexus-cloud-lb:[Cloud]:Cloud Load Balancer (ALB)"
    "nexus-cloud-app:[Cloud]:Cloud Microservice (SSRF vuln)"
    "nexus-cloud-db:[Cloud]:Cloud Managed DB (RDS sim)"
    "nexus-saas-sso:[Cloud]:SaaS SSO Portal (SAML/OAuth2)"
)

# Auto-detect mode if not specified
if [ "$MODE" = "auto" ]; then
    RUNNING_CLOUD=$(docker inspect -f "{{.State.Status}}" nexus-cloud-app 2>/dev/null)
    RUNNING_ENT=$(docker inspect -f "{{.State.Status}}" nexus-ztna-gateway 2>/dev/null)
    RUNNING_CORE=$(docker inspect -f "{{.State.Status}}" nexus-edge-router 2>/dev/null)

    if [ "$RUNNING_CLOUD" = "running" ]; then
        MODE="all"
    elif [ "$RUNNING_ENT" = "running" ]; then
        MODE="enterprise"
    elif [ "$RUNNING_CORE" = "running" ]; then
        MODE="core"
    else
        MODE="all"
    fi
fi

TARGET_LIST=()
case "$MODE" in
    core)
        TARGET_LIST=("${CORE_CONTAINERS[@]}")
        TITLE="Mode 1: Standard Infrastructure (13 Nodes)"
        ;;
    enterprise)
        TARGET_LIST=("${CORE_CONTAINERS[@]}" "${ENTERPRISE_CONTAINERS[@]}")
        TITLE="Mode 2: Advanced Enterprise (29 Nodes)"
        ;;
    cloud)
        TARGET_LIST=("${CLOUD_CONTAINERS[@]}")
        TITLE="Cloud Tier Only (5 Nodes)"
        ;;
    *)
        TARGET_LIST=("${CORE_CONTAINERS[@]}" "${ENTERPRISE_CONTAINERS[@]}" "${CLOUD_CONTAINERS[@]}")
        TITLE="Mode 3: Full Hybrid Cloud (34 Nodes)"
        ;;
esac

echo -e "[1;36m============================================================[0m"
echo -e "[1;33m [?] Nexus Enterprise Lab - Health Diagnostic[0m"
echo -e "[1;36m Scope: $TITLE[0m"
echo -e "[1;36m============================================================[0m"

RUNNING=0
TOTAL=${#TARGET_LIST[@]}
ERRORS=0

for item in "${TARGET_LIST[@]}"; do
    IFS=":" read -r name zone role <<< "$item"
    STATUS=$(docker inspect -f "{{.State.Status}}" "$name" 2>/dev/null)
    if [ "$STATUS" = "running" ]; then
        printf "  [1;32m[v] %-32s %-10s %s[0m
" "$name" "$zone" "$role"
        ((RUNNING++))
    elif [ -z "$STATUS" ]; then
        printf "  [0;90m[o] %-32s %-10s %s  [not deployed][0m
" "$name" "$zone" "$role"
    else
        printf "  [1;31m[x] %-32s %-10s %s  [%s][0m
" "$name" "$zone" "$role" "$STATUS"
        ((ERRORS++))
    fi
done

echo ""
echo -e "[0;90m============================================================[0m"
echo -e "[1;36m  Scope: ${MODE^^} | Running: $RUNNING/$TOTAL | Errors: $ERRORS[0m"

if [ "$RUNNING" -eq "$TOTAL" ] && [ "$TOTAL" -gt 0 ]; then
    echo -e "[1;32m  [+] All containers in this scope are HEALTHY and ONLINE![0m"
elif [ "$ERRORS" -gt 0 ]; then
    echo -e "[1;31m  [!] $ERRORS container(s) failed. Run 'docker compose logs' for details.[0m"
fi
echo ""
