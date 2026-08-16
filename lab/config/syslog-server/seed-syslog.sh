#!/bin/bash
# Seed synthetic syslog events for Blue-Team analysis exercises
# Then start rsyslog daemon

mkdir -p /var/log/nexus-syslog /var/log/nexus-alerts

# Seed realistic synthetic log entries
cat > /var/log/nexus-syslog/nexus-all.log << 'SYSLOG'
2026-08-15T02:00:01Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:00:01 +0000] "GET /robots.txt HTTP/1.1" 200 412 Zone=DMZ
2026-08-15T02:00:14Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:00:14 +0000] "GET /changelog.txt HTTP/1.1" 200 612 Zone=DMZ
2026-08-15T02:01:03Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:01:03 +0000] "GET /api/v1/status HTTP/1.1" 200 389 Zone=DMZ
2026-08-15T02:03:44Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:03:44 +0000] "GET /admin-console/ HTTP/1.1" 403 98 Zone=DMZ
2026-08-15T02:05:12Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:05:12 +0000] "GET /?track_id=NX-98231'-- HTTP/1.1" 200 2819 Zone=DMZ
2026-08-15T02:05:33Z srv-waf-proxy nginx: 198.51.100.100 - - [15/Aug/2026:02:05:33 +0000] "GET /?track_id=NX-1' UNION SELECT username,password,role,full_name,1,1 FROM portal_users-- HTTP/1.1" 200 3210 Zone=DMZ
2026-08-15T02:06:01Z srv-dmz-web01 portal: [AUTH] LOGIN_SUCCESS user=admin src=198.51.100.100 method=POST /login
2026-08-15T02:07:18Z srv-dmz-web01 portal: [CMDINJ] ALERT: host field contains shell metacharacters: host=127.0.0.1; id src=198.51.100.100
2026-08-15T02:07:19Z srv-dmz-web01 portal: [CMDINJ] ALERT: Executing: ping -c 2 -W 2 127.0.0.1; id src=198.51.100.100
2026-08-15T02:10:05Z fw-perimeter-01 kernel: [HQ-FW-BLOCKED]: IN=eth0 OUT=eth2 SRC=10.0.1.20 DST=10.0.3.20 PROTO=TCP DPT=5432 (Direct DB access from DMZ blocked)
2026-08-15T02:11:34Z fw-perimeter-01 kernel: [HQ-FW-BLOCKED]: IN=eth0 OUT=eth1 SRC=198.51.100.100 DST=10.0.2.10 PROTO=TCP DPT=389 (Direct LDAP from WAN blocked)
2026-08-15T02:15:00Z dc01 smbd: [SMB] CONNECT from 10.0.1.20 share=IT-Backups user=nobody (guest)
2026-08-15T02:15:01Z dc01 smbd: [SMB] FILE_READ from 10.0.1.20 share=IT-Backups file=sync_prod_db.sh user=nobody
2026-08-15T02:15:02Z dc01 smbd: [SMB] FILE_READ from 10.0.1.20 share=IT-Backups file=INFRA_RUNBOOK.txt user=nobody
2026-08-15T02:19:40Z db-prod-01 postgres: [AUTH] connection received: host=10.0.3.10 user=nexus_admin database=nexus_prod SSL=off
2026-08-15T02:19:40Z db-prod-01 postgres: [SQL] SELECT * FROM system_vault_keys; user=nexus_admin host=10.0.3.10
2026-08-15T02:19:41Z db-prod-01 postgres: [SQL] SELECT * FROM api_keys; user=nexus_admin host=10.0.3.10
SYSLOG

cat > /var/log/nexus-alerts/firewall-blocks.log << 'FWLOGS'
[ALERT] 2026-08-15T02:10:05Z HOST:fw-perimeter-01 PROG:kernel [HQ-FW-BLOCKED]: SRC=10.0.1.20 DST=10.0.3.20 PROTO=TCP DPT=5432
[ALERT] 2026-08-15T02:11:34Z HOST:fw-perimeter-01 PROG:kernel [HQ-FW-BLOCKED]: SRC=198.51.100.100 DST=10.0.2.10 PROTO=TCP DPT=389
[ALERT] 2026-08-14T11:24:55Z HOST:srv-waf-proxy PROG:nginx BLOCKED: /admin-console/ from 198.51.100.50
FWLOGS

cat > /var/log/nexus-alerts/auth-failures.log << 'AUTHLOGS'
[ALERT] 2026-08-14T11:23:10Z HOST:srv-dmz-web01 PROG:portal AUTH_FAIL: username=admin src=198.51.100.50 attempt=1
[ALERT] 2026-08-14T11:23:11Z HOST:srv-dmz-web01 PROG:portal AUTH_FAIL: username=admin src=198.51.100.50 attempt=2
[ALERT] 2026-08-14T11:23:12Z HOST:srv-dmz-web01 PROG:portal AUTH_FAIL: username=logistics src=198.51.100.50 attempt=3
[ALERT] 2026-08-14T11:23:55Z HOST:srv-dmz-web01 PROG:portal AUTH_FAIL: username=admin src=198.51.100.50 attempt=34
AUTHLOGS

echo "[+] Nexus Enterprise SIEM Syslog Collector is ACTIVE."
echo "[+] Listening on UDP/TCP port 514 for incoming syslog."
echo "[+] Log files available at:"
echo "    /var/log/nexus-syslog/nexus-all.log"
echo "    /var/log/nexus-alerts/firewall-blocks.log"
echo "    /var/log/nexus-alerts/auth-failures.log"
echo ""
echo "[+] Use 'tail -f /var/log/nexus-syslog/nexus-all.log' for live monitoring."

# Start rsyslog in foreground
exec rsyslogd -n -f /etc/rsyslog.conf
