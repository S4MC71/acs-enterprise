#!/bin/bash
# Samba Domain Controller Startup (Nexus Global Enterprise)
# Domain: NEXUS | Realm: NEXUS.INTERNAL | IP: 10.0.2.10

set -e

echo "[*] Initializing Nexus Enterprise Samba Domain Controller..."

# Ensure runtime directories exist
mkdir -p /run/samba /var/cache/samba /var/lib/samba/lock

# Create guest/nobody user if missing (required for anonymous share access)
id -u nobody &>/dev/null || adduser -D -H -S -G nobody nobody 2>/dev/null || true

# Setup tdb databases if not present
if [ ! -f /var/lib/samba/private/passdb.tdb ]; then
    tdbtool /var/lib/samba/private/passdb.tdb create 2>/dev/null || true
fi

# Initialize Samba user database (passdb.tdb)
(echo ""; echo "") | smbpasswd -a nobody 2>/dev/null || true

echo "[+] Samba share directories:"
ls -la /shared/

echo "[*] Starting Samba daemons (smbd + nmbd)..."

# Start nmbd (NetBIOS name service) in background
nmbd --daemon --no-process-group --configfile=/etc/samba/smb.conf \
     --log-basename=/var/log/samba/nmbd 2>/dev/null &
NMBD_PID=$!

# Small delay for nmbd
sleep 1

# Start smbd (SMB file sharing) in foreground
echo "[+] smbd and nmbd are running."
echo "[+] SMB shares available at: \\\\10.0.2.10\\"
echo "[+]   IT-Backups  (anonymous read)"
echo "[+]   HR-Public   (anonymous read)"
echo "[+]   netlogon    (anonymous read)"

exec smbd --foreground --no-process-group --configfile=/etc/samba/smb.conf \
     --log-basename=/var/log/samba/smbd
