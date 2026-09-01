FROM debian:bookworm-slim

# Install Samba4 AD DC + all required components
RUN apt-get update && apt-get install -y --no-install-recommends \
    samba \
    samba-common-bin \
    samba-dsdb-modules \
    samba-vfs-modules \
    winbind \
    libpam-winbind \
    libnss-winbind \
    krb5-user \
    dnsutils \
    iproute2 \
    iputils-ping \
    net-tools \
    bash \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Create shared directories
RUN mkdir -p \
    /shared/IT-Backups \
    /shared/HR-Public \
    /var/log/samba \
    /var/lib/samba/private

# ── IT-Backups Share Content (main attack artifact) ───────────────────────────
COPY share-content/IT-Backups/ /shared/IT-Backups/

# ── HR-Public Share Content ───────────────────────────────────────────────────
COPY share-content/HR-Public/  /shared/HR-Public/

# Publicly readable — simulates misconfigured share permissions
RUN chmod -R 755 /shared && \
    chmod 644 /shared/IT-Backups/* /shared/HR-Public/* 2>/dev/null || true

# Startup script (handles provisioning + Samba start)
COPY start-ad.sh /usr/local/bin/start-ad.sh
RUN chmod +x /usr/local/bin/start-ad.sh

# AD DC Ports:
#   53  — DNS (Samba internal)
#   88  — Kerberos KDC
#   135 — RPC Endpoint Mapper
#   137/138 — NetBIOS Name/Datagram
#   139/445 — SMB/CIFS
#   389 — LDAP
#   636 — LDAPS
#   3268/3269 — Global Catalog LDAP/LDAPS
EXPOSE 53/tcp 53/udp
EXPOSE 88/tcp 88/udp
EXPOSE 135/tcp
EXPOSE 137/udp 138/udp 139/tcp
EXPOSE 389/tcp 389/udp
EXPOSE 445/tcp
EXPOSE 636/tcp
EXPOSE 3268/tcp 3269/tcp

CMD ["/usr/local/bin/start-ad.sh"]
