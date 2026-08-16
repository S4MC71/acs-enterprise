#!/bin/bash
# Nexus Enterprise Lab — Profile-aware Start Script (Linux/macOS)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LAB_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║    NEXUS GLOBAL ENTERPRISE — PENTESTING LAB LAUNCHER         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "  Select Lab Mode:"
echo ""
echo "  [1] STANDARD LAB (Core)       ~14 containers | ~4 GB RAM"
echo "  [2] LARGE ENTERPRISE           ~28 containers | ~8 GB RAM"
echo "  [3] FULL (Enterprise + Cloud)  ~33 containers | ~10-12 GB RAM"
echo "  [4] CLOUD TIER ONLY            ~5 containers  | ~2 GB RAM"
echo "  [Q] Quit"
echo ""
read -rp "  Enter choice [1/2/3/4/Q]: " CHOICE

case "$CHOICE" in
  1) PROFILES="--profile core";                       LABEL="Standard Lab"           ;;
  2) PROFILES="--profile core --profile enterprise";  LABEL="Large Enterprise"       ;;
  3) PROFILES="--profile core --profile enterprise --profile cloud"; LABEL="Full"   ;;
  4) PROFILES="--profile cloud";                      LABEL="Cloud Tier Only"        ;;
  Q|q) echo "Exiting."; exit 0 ;;
  *) PROFILES="--profile core"; LABEL="Standard Lab (default)" ;;
esac

echo ""
echo "[*] Mode: $LABEL"
echo "[*] Running: docker compose $PROFILES up -d --build"
echo ""

cd "$LAB_DIR" || exit 1
docker compose $PROFILES up -d --build

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Lab is starting!"
    echo ""
    echo "  Corporate Portal:   http://localhost:80"
    echo "  Corporate Webmail:  http://localhost:8025"
    echo "  SSH Bastion:        ssh devops-remote@localhost -p 2222"
    if echo "$PROFILES" | grep -q "enterprise"; then
        echo "  Grafana NMS:        http://localhost:3000"
        echo "  RTSP Camera:        rtsp://localhost:8554/nexus-lobby"
        echo "  Camera HLS:         http://localhost:8888/nexus-lobby/"
    fi
    if echo "$PROFILES" | grep -q "cloud"; then
        echo "  Cloud App:          http://localhost:8090"
        echo "  SaaS SSO:           http://localhost:8443"
    fi
    echo ""
    echo "  Pentest:   Use your local Kali/WSL environment (see docs/attacker_tools_guide.md)"
    echo "  Health:    ./scripts/check-health.sh"
else
    echo ""
    echo "❌ Startup failed. Check errors above."
fi
