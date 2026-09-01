#!/bin/bash
# ============================================================
# Nexus Global Enterprise — Samba4 Active Directory DC
# Domain:  NEXUS
# Realm:   NEXUS.INTERNAL
# DC IP:   10.0.2.10
# Host:    dc01.nexus.internal
#
# IDEMPOTENT: provisioning only runs on first container start.
# Subsequent restarts skip directly to `exec samba`.
# ============================================================

set -e

DOMAIN="NEXUS"
REALM="NEXUS.INTERNAL"
ADMIN_PASS="NexusDCAdmin2026!"
DC_IP="10.0.2.10"

echo "============================================================"
echo "  Nexus Global Enterprise — Active Directory DC (dc01)"
echo "  Domain: ${REALM} | IP: ${DC_IP}"
echo "============================================================"

# Ensure /etc/hosts has the DC's FQDN (required for Kerberos)
if ! grep -q "dc01.nexus.internal" /etc/hosts; then
    echo "${DC_IP}  dc01.nexus.internal dc01" >> /etc/hosts
fi

# ─────────────────────────────────────────────────────────────────────────────
# FIRST RUN: Provision the AD domain
# ─────────────────────────────────────────────────────────────────────────────
if [ ! -f /var/lib/samba/private/sam.ldb ]; then

    echo "[*] First run detected — provisioning NEXUS.INTERNAL domain..."

    # Remove any stale smb.conf so samba-tool can generate a fresh one
    rm -f /etc/samba/smb.conf

    samba-tool domain provision \
        --use-rfc2307 \
        --domain="${DOMAIN}" \
        --realm="${REALM}" \
        --server-role=dc \
        --dns-backend=SAMBA_INTERNAL \
        --adminpass="${ADMIN_PASS}" \
        --option="interfaces=lo eth0" \
        --option="bind interfaces only=yes" \
        --option="log level=1" \
        --option="dns forwarder=8.8.8.8" \
        --option="server min protocol=SMB2"

    echo "[+] Domain provisioned."

    # ── Append custom SMB file shares to generated smb.conf ──────────────────
    cat >> /etc/samba/smb.conf << 'SHARES_EOF'

# ════════════════════════════════════════════════════════════════
#   Nexus Enterprise File Shares
# ════════════════════════════════════════════════════════════════

[IT-Backups]
   comment = IT Engineering Backup & Deployment Scripts (RESTRICTED)
   path = /shared/IT-Backups
   browseable = yes
   guest ok = yes
   read only = yes

[HR-Public]
   comment = HR Department Shared Policies & Onboarding Guides
   path = /shared/HR-Public
   browseable = yes
   guest ok = yes
   read only = yes
SHARES_EOF

    echo "[+] Custom SMB shares added (IT-Backups, HR-Public)."

    # ── Organisational Units ──────────────────────────────────────────────────
    echo "[*] Creating Organisational Units..."
    samba-tool ou create "OU=Executive,DC=nexus,DC=internal"   2>/dev/null || true
    samba-tool ou create "OU=IT,DC=nexus,DC=internal"          2>/dev/null || true
    samba-tool ou create "OU=HR,DC=nexus,DC=internal"          2>/dev/null || true
    samba-tool ou create "OU=Finance,DC=nexus,DC=internal"     2>/dev/null || true
    samba-tool ou create "OU=ServiceAccounts,DC=nexus,DC=internal" 2>/dev/null || true
    samba-tool ou create "OU=Workstations,DC=nexus,DC=internal"    2>/dev/null || true
    samba-tool ou create "OU=Servers,DC=nexus,DC=internal"         2>/dev/null || true
    echo "[+] OUs created."

    # ── Domain Admin Accounts ─────────────────────────────────────────────────
    echo "[*] Creating domain admin accounts..."

    # Marcus Vance — CISO / Domain Admin
    samba-tool user create mvance 'M@rcusV@nce2026!Admin' \
        --given-name=Marcus --surname=Vance \
        --job-title="Chief Information Security Officer" \
        --department="Executive" \
        --mail-address="mvance@nexus.internal" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move mvance "OU=Executive,DC=nexus,DC=internal" 2>/dev/null || true
    samba-tool group addmembers "Domain Admins" mvance 2>/dev/null || true

    # Elena Rostova — Lead Infrastructure Architect / Domain Admin
    samba-tool user create erostova '3l3naR0stov@Arch!' \
        --given-name=Elena --surname=Rostova \
        --job-title="Lead Infrastructure Architect" \
        --department="IT" \
        --mail-address="erostova@nexus.internal" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move erostova "OU=IT,DC=nexus,DC=internal" 2>/dev/null || true
    samba-tool group addmembers "Domain Admins" erostova 2>/dev/null || true

    echo "[+] Domain admins: mvance, erostova"

    # ── Domain User Accounts ──────────────────────────────────────────────────
    echo "[*] Creating domain user accounts..."

    # Tanvir Ahmed — DevOps Lead
    samba-tool user create tahmed 'DevOpsP@ss2026!' \
        --given-name=Tanvir --surname=Ahmed \
        --job-title="DevOps & SRE Lead" \
        --department="IT" \
        --mail-address="tahmed@nexus.internal" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move tahmed "OU=IT,DC=nexus,DC=internal" 2>/dev/null || true

    # Sarah Jenkins — HR Manager
    samba-tool user create sjenkins 'HR$ecure2026' \
        --given-name=Sarah --surname=Jenkins \
        --job-title="HR Manager" \
        --department="Human Resources" \
        --mail-address="sjenkins@nexus.internal" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move sjenkins "OU=HR,DC=nexus,DC=internal" 2>/dev/null || true

    # Amina Rahman — Financial Auditor
    samba-tool user create arahman 'Fin@ncial2026!' \
        --given-name=Amina --surname=Rahman \
        --job-title="Financial Auditor" \
        --department="Finance" \
        --mail-address="arahman@nexus.internal" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move arahman "OU=Finance,DC=nexus,DC=internal" 2>/dev/null || true

    echo "[+] Domain users: tahmed, sjenkins, arahman"

    # ── Department Groups ─────────────────────────────────────────────────────
    echo "[*] Creating department groups..."

    samba-tool group add "IT-Engineering" \
        --description="IT Engineering, DevOps & SRE Team" 2>/dev/null || true
    samba-tool group addmembers "IT-Engineering" tahmed,erostova 2>/dev/null || true

    samba-tool group add "HR-Department" \
        --description="Human Resources Department" 2>/dev/null || true
    samba-tool group addmembers "HR-Department" sjenkins 2>/dev/null || true

    samba-tool group add "Finance-Team" \
        --description="Finance & Internal Audit Team" 2>/dev/null || true
    samba-tool group addmembers "Finance-Team" arahman 2>/dev/null || true

    samba-tool group add "IT-Admins" \
        --description="IT Administrators — Elevated System Access" 2>/dev/null || true
    samba-tool group addmembers "IT-Admins" mvance,erostova 2>/dev/null || true

    echo "[+] Groups: IT-Engineering, HR-Department, Finance-Team, IT-Admins"

    # ── Service Accounts (realistic enterprise structure) ─────────────────────
    echo "[*] Creating service accounts..."

    samba-tool user create svc_backup 'Backup$vc2019!' \
        --description="Nightly DB Backup Automation — DO NOT DISABLE" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move svc_backup "OU=ServiceAccounts,DC=nexus,DC=internal" 2>/dev/null || true

    samba-tool user create svc_mssql 'Sql$vc2024Nexus!' \
        --description="SQL Server / PostgreSQL Service Account" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move svc_mssql "OU=ServiceAccounts,DC=nexus,DC=internal" 2>/dev/null || true

    samba-tool user create svc_web 'W3bS3rv1ce@nexus' \
        --description="Corporate Web Portal Service Account" \
        --use-username-as-cn 2>/dev/null || true
    samba-tool user move svc_web "OU=ServiceAccounts,DC=nexus,DC=internal" 2>/dev/null || true

    echo "[+] Service accounts: svc_backup, svc_mssql, svc_web"

    # ── Kerberos config ───────────────────────────────────────────────────────
    # Copy Samba-generated krb5.conf for tools that need it
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf 2>/dev/null || true

    echo ""
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   NEXUS GLOBAL ENTERPRISE — AD DC PROVISIONING DONE     ║"
    echo "║                                                          ║"
    echo "║   Domain:   NEXUS.INTERNAL                              ║"
    echo "║   DC:       dc01.nexus.internal (10.0.2.10)             ║"
    echo "║   Admin:    Administrator / NexusDCAdmin2026!           ║"
    echo "║                                                          ║"
    echo "║   Domain Admins:  mvance, erostova                      ║"
    echo "║   Domain Users:   tahmed, sjenkins, arahman             ║"
    echo "║   Service Accts:  svc_backup, svc_mssql, svc_web       ║"
    echo "║                                                          ║"
    echo "║   SMB Shares:                                           ║"
    echo "║     \\\\10.0.2.10\\IT-Backups  (anonymous read)           ║"
    echo "║     \\\\10.0.2.10\\HR-Public   (anonymous read)           ║"
    echo "╚══════════════════════════════════════════════════════════╝"

else
    echo "[+] AD already provisioned — skipping (sam.ldb exists)."
    # Ensure /etc/krb5.conf is in place after container rebuild
    cp /var/lib/samba/private/krb5.conf /etc/krb5.conf 2>/dev/null || true
fi

echo ""
echo "[*] Starting Samba AD DC..."
exec samba --foreground --no-process-group --log-stdout
