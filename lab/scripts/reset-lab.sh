#!/bin/bash
# Nexus Enterprise Lab Reset Script - Linux/macOS

echo -e "\033[1;33m============================================================\033[0m"
echo -e "\033[1;33m 🧹 Resetting Nexus Enterprise Lab to Clean State...\033[0m"
echo -e "\033[1;33m============================================================\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

docker compose down -v --remove-orphans

echo ""
echo -e "\033[1;32m[+] All containers, networks, and lab state removed successfully.\033[0m"
