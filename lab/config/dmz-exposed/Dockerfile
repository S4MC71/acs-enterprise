FROM alpine:3.19

# ─────────────────────────────────────────────────────────────────
#  nexus-dmz-exposed  |  Intentionally Vulnerable DMZ Service
#  Services: FTP (anon) · Telnet (weak creds) · SNMP (public) · PostgreSQL (weak)
#  Purpose:  Black-Box network pentesting entry point
# ─────────────────────────────────────────────────────────────────

RUN apk add --no-cache \
    vsftpd \
    busybox-extras \
    net-snmp \
    net-snmp-tools \
    postgresql15 \
    postgresql15-contrib \
    bash \
    shadow \
    su-exec \
    procps \
    iproute2 \
    net-tools \
    socat \
    curl \
    wget

# ── Weak credential users ─────────────────────────────────────────
# Telnet: sysadmin / nexus123
# PostgreSQL: monitor / monitor123
RUN adduser -D -s /bin/sh sysadmin && \
    echo "sysadmin:nexus123" | chpasswd && \
    adduser -D -s /bin/sh monitoruser && \
    echo "monitoruser:monitor123" | chpasswd

# ── FTP Setup (anonymous login) ───────────────────────────────────
RUN mkdir -p /var/ftp/pub
COPY ftp-files/ /var/ftp/pub/
RUN chmod 755 /var/ftp && \
    chmod -R 644 /var/ftp/pub && \
    find /var/ftp/pub -type d -exec chmod 755 {} \;
COPY vsftpd.conf /etc/vsftpd/vsftpd.conf

# ── SNMP Setup (public community string) ─────────────────────────
COPY snmpd.conf /etc/snmp/snmpd.conf

# ── PostgreSQL Setup ──────────────────────────────────────────────
RUN mkdir -p /var/lib/postgresql/data /run/postgresql && \
    chown -R postgres:postgres /var/lib/postgresql /run/postgresql
COPY init.sql /tmp/init.sql

# ── Sysadmin home breadcrumbs (realistic lateral movement hints) ──
COPY hosts.custom /etc/hosts.custom

RUN mkdir -p /home/sysadmin/.ssh /home/sysadmin/scripts && \
    chown -R sysadmin:sysadmin /home/sysadmin

RUN printf '%s\n' \
    "ping -c 2 10.0.2.10" \
    "ssh admin@10.0.2.10" \
    "smbclient -L //10.0.2.10 -N" \
    "snmpwalk -v2c -c public 10.0.1.10" \
    "psql -h 10.0.3.20 -U nexus_admin -d nexus_prod" \
    "cat /home/sysadmin/scripts/monitor.sh" \
    "ping -c 2 10.0.3.20" \
    > /home/sysadmin/.ash_history && \
    chown sysadmin:sysadmin /home/sysadmin/.ash_history

RUN printf '%s\n' \
    "#!/bin/sh" \
    "# Nexus DMZ Monitoring Script — runs every 5 min via cron" \
    "# Contacts: it-ops@nexus.internal  |  NOC: noc@nexus.internal" \
    "" \
    "AD_DC=10.0.2.10" \
    "PROD_DB=10.0.3.20" \
    "ERP_HOST=10.0.3.10" \
    "BACKUP_SAN=10.0.3.30" \
    "SIEM=10.0.2.99" \
    "" \
    "# Check AD DC health" \
    "ping -c 1 \$AD_DC > /dev/null 2>&1 && echo '[OK] AD DC reachable' || echo '[FAIL] AD DC unreachable'" \
    "# Check Production DB" \
    "ping -c 1 \$PROD_DB > /dev/null 2>&1 && echo '[OK] Prod DB reachable' || echo '[FAIL] Prod DB unreachable'" \
    > /home/sysadmin/scripts/monitor.sh && \
    chmod +x /home/sysadmin/scripts/monitor.sh && \
    chown -R sysadmin:sysadmin /home/sysadmin/scripts

# ── Entrypoint ────────────────────────────────────────────────────
COPY start.sh /start.sh
RUN chmod +x /start.sh

# FTP control + PASV range + Telnet + SNMP + PostgreSQL
EXPOSE 21 21100-21110 23 161/udp 5432

CMD ["/start.sh"]
