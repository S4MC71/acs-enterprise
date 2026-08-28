#!/bin/bash
# ─────────────────────────────────────────────────────────────────
#  nexus-dmz-exposed  |  Multi-Service Entrypoint
#  Starts: FTP · Telnet · SNMP · PostgreSQL
# ─────────────────────────────────────────────────────────────────
# set -e intentionally removed — individual service failures should not crash container

echo "=============================================="
echo " NEXUS GLOBAL ENTERPRISE - DMZ Monitor Node  "
echo " Initializing services...                    "
echo "=============================================="

# ── 1. Append internal hosts to /etc/hosts ────────────────────────
echo "[*] Loading internal host entries..."
cat /etc/hosts.custom >> /etc/hosts

# ── 2. Configure PASV address for FTP ─────────────────────────────
# Set PUBLIC_IP env var when deploying to VPS: -e PUBLIC_IP=<VPS_PUBLIC_IP>
PASV_ADDR="${PUBLIC_IP:-0.0.0.0}"
echo "[*] Configuring FTP PASV address: $PASV_ADDR"
sed -i "s/PASV_PLACEHOLDER/${PASV_ADDR}/" /etc/vsftpd/vsftpd.conf

# ── 3. Start FTP (vsftpd anonymous) ──────────────────────────────
echo "[*] Starting FTP service (port 21)..."
vsftpd /etc/vsftpd/vsftpd.conf &
FTP_PID=$!
echo "[+] FTP started (PID: $FTP_PID)"

# ── 4. Start Telnet via socat (proper PTY/TTY support) ──────────────────
echo "[*] Starting Telnet service (port 23)..."
# socat creates a proper pseudo-terminal (PTY) so /bin/login works correctly
socat TCP-LISTEN:23,fork,reuseaddr EXEC:'/bin/login',pty,setsid,setpgid,stderr,rawer &
TELNET_PID=$!
echo "[+] Telnet started via socat (PID: $TELNET_PID)"

# ── 5. Start SNMP (net-snmpd with public community) ──────────────
echo "[*] Starting SNMP service (port 161/udp)..."
# -C = ignore all default config files, only use -c specified file
# -I -hrh = skip host resources handler (avoids /proc/net/snmp kernel mismatch)
snmpd -C -Lo -f -c /etc/snmp/snmpd.conf -I -hrh &
SNMP_PID=$!
echo "[+] SNMP started (PID: $SNMP_PID)"

# ── 6. Initialize PostgreSQL ──────────────────────────────────────
echo "[*] Initializing PostgreSQL..."
if [ ! -f /var/lib/postgresql/data/PG_VERSION ]; then
    su-exec postgres initdb -D /var/lib/postgresql/data --auth=md5 --username=postgres > /dev/null 2>&1
    echo "[+] PostgreSQL data directory initialized"
fi

# Allow remote connections
grep -q "listen_addresses" /var/lib/postgresql/data/postgresql.conf 2>/dev/null || true
echo "listen_addresses = '*'" >> /var/lib/postgresql/data/postgresql.conf

# Configure pg_hba for monitoring_db access (md5 from anywhere)
cat >> /var/lib/postgresql/data/pg_hba.conf << 'HBA_EOF'
host    monitoring_db   monitor         0.0.0.0/0               md5
host    all             postgres        127.0.0.1/32            trust
HBA_EOF


echo "[*] Starting PostgreSQL (port 5432)..."
su-exec postgres pg_ctl start -D /var/lib/postgresql/data -w -l /tmp/pg.log > /dev/null 2>&1
echo "[+] PostgreSQL started"

# Initialize monitoring database (runs once)
echo "[*] Seeding monitoring database..."
su-exec postgres psql -c "CREATE USER monitor WITH PASSWORD 'monitor123';" 2>/dev/null || true
su-exec postgres psql -c "CREATE DATABASE monitoring_db OWNER monitor;" 2>/dev/null || true
su-exec postgres psql -d monitoring_db -f /tmp/init.sql > /dev/null 2>&1 || true
echo "[+] monitoring_db ready"

echo ""
echo "=============================================="
echo " All services active:"
echo "   FTP     : port 21 (anonymous)"
echo "   Telnet  : port 23 (sysadmin/nexus123)"
echo "   SNMP    : port 161/udp (community: public)"
echo "   PgSQL   : port 5432 (monitor/monitor123)"
echo "=============================================="

# Keep container alive
tail -f /dev/null
