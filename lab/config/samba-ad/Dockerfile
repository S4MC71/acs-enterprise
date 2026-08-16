FROM alpine:3.19

RUN apk add --no-cache \
    samba \
    samba-common-tools \
    iproute2 \
    iputils \
    bash \
    bind-tools \
    shadow \
    tdb-tools \
    coreutils

# Create samba runtime directories
RUN mkdir -p \
    /var/lib/samba/sysvol/nexus.internal/scripts \
    /var/lib/samba/private \
    /var/lib/samba/lock \
    /var/cache/samba \
    /run/samba \
    /shared/IT-Backups \
    /shared/HR-Public \
    /shared/SYSVOL \
    /var/log/samba

# ── IT-Backups Share Content ──────────────────────────────────────────────────
# Primary attack artifact: hardcoded DB credentials in nightly sync script
COPY share-content/IT-Backups/ /shared/IT-Backups/

# ── HR-Public Share Content ───────────────────────────────────────────────────
COPY share-content/HR-Public/ /shared/HR-Public/

# Set permissions (all publicly readable - simulates misconfigured share)
RUN chmod -R 755 /shared && \
    chmod 644 /shared/IT-Backups/* /shared/HR-Public/* 2>/dev/null || true

COPY smb.conf /etc/samba/smb.conf
COPY start-ad.sh /usr/local/bin/start-ad.sh
RUN chmod +x /usr/local/bin/start-ad.sh

# Expose SMB, NetBIOS, and LDAP simulation ports
EXPOSE 137/udp 138/udp 139 445

CMD ["/usr/local/bin/start-ad.sh"]
