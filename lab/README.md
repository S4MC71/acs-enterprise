# 🏢 Nexus Global Enterprise — Penetration Testing & Network Architecture Lab

> **A fully realistic, Docker-based Enterprise Network simulation for cybersecurity education, penetration testing practice, and network architecture exploration.**

Explore the live interactive topology map anytime by opening [**`enterprise-network.html`**](./enterprise-network.html) in your browser!

---

## ⚡ Quick Launch Cheatsheet

```powershell
cd lab

# 1. Start Lab in your desired mode:
.\scripts\start-lab.ps1 -Mode core          # 🛡️ Mode 1: Standard Lab (13 containers, ~4GB RAM)
.\scripts\start-lab.ps1 -Mode enterprise    # 🏢 Mode 2: Advanced Enterprise (28 containers, ~8GB RAM)
.\scripts\start-lab.ps1 -Mode all           # ☁️ Mode 3: Full Hybrid Cloud (33 containers, ~12GB RAM)

# 2. Check which containers are running vs stopped:
.\scripts\check-health.ps1

# 3. Stop or Reset:
docker compose --profile core --profile enterprise --profile cloud down  # Stop (preserves data)
.\scripts\reset-lab.ps1                                                # Full Wipe & Reset
```
*(Linux / macOS users: use `./scripts/start-lab.sh` and `./scripts/check-health.sh`)*

---

## 🗺️ Lab Modes Breakdown (কী কী এভেইলেবল আছে মোড অনুযায়ী)

---

### 🛡️ MODE 1: Standard Infrastructure (`core`)
> **Hardware:** 13 Containers | ~4 GB RAM  
> **Command:** `.\scripts\start-lab.ps1 -Mode core`  
> **Focus:** Web Application Security, WAF Evasion, SQLi, Command Injection, Active Directory Enumeration, Database Crown Jewels.

#### 🌐 1. Browser Web Applications (সরাসরি ব্রাউজারে ওপেন করুন)
| Application | URL | Role & Description | Default Credentials |
|:---|:---|:---|:---|
| **Corporate Web Portal** | [`http://localhost:80`](http://localhost:80) | Customer tracking & shipping portal (behind Nginx WAF). Contains SQLi & Admin Command Injection. | `admin` / `NexusTechAdmin2026!` |
| **MailHog Webmail** | [`http://localhost:8025`](http://localhost:8025) | Webmail inbox capturing all internal corporate emails, notifications, and password resets. | *No password required* |
| **MinIO Primary SAN** | [`http://localhost:9001`](http://localhost:9001) | S3-compatible primary storage SAN console. | `nexus_san_root` / `SuperS3cUr3_B4ckup_Vault_Pass_2026!` |

#### 🔌 2. CLI & Network Services (টার্মিনাল / ডেডিকেটেড টুলস দিয়ে টেস্ট করুন)
| Service | Access Command / Method | Port / Protocol | Details |
|:---|:---|:---|:---|
| **SSH Bastion Jump Host** | `ssh devops-remote@localhost -p 2222` | Port `2222` (SSH) | Password: `devops-remote@123`<br>*(Pivot point into Core & Campus subnets)* |
| **PostgreSQL Crown Jewels** | `docker exec -it nexus-dc-prod-database psql -U nexus_admin -d nexus_prod` | Port `5432` (Postgres) | User: `nexus_admin`<br>Pass: `Nexu$$Prod2026!Sec`<br>*(Contains `system_vault_keys` table with Flag 3)* |
| **Active Directory DC** | `smbclient -L //10.0.2.10 -N` | Port `445` (SMB), `389` (LDAP) | Admin: `Administrator` / `NexusAD2026!Admin`<br>*(Unauthenticated SMB share leaks DB script)* |
| **SIEM / SOC Collector** | `docker exec -it nexus-corp-siem-soc bash` | Port `514` (Syslog) | Blue-Team log analysis: `tail -f /var/log/nexus-syslog/nexus-all.log` |
| **Internal ERP Intranet** | Internal access: `http://10.0.3.10:8000` | Port `8000` (HTTP) | Internal corporate financial and payroll web service |

#### 💻 3. Gray-Box Workstations (এমপ্লয়ি পিসিতে সরাসরি শেল এক্সেস)
```bash
# DevOps Engineer Workstation (tahmed) — has Docker access, git history, SSH keys:
docker exec -it nexus-pc-dev-01 bash     # Credentials: tahmed / DevOpsP@ss2026!

# HR Director Workstation (sjenkins) — contains employee rosters & salary documents:
docker exec -it nexus-pc-hr-01 bash      # Credentials: sjenkins / HrDirector9921!
```

#### 🚩 4. CTF Flags in Mode 1
- 🟢 **Flag 1 (SQLi):** `FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026}` — Found on Web Portal `/?track_id=`
- 🟡 **Flag 2 (CMDi):** `FLAG{CMD_INJ3CT10N_PORTAL_COMPR0M1S3D}` — Found in Web Admin `/admin/server-check`
- 🔴 **Flag 3 (Crown Jewels):** `FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}` — Found in PostgreSQL `system_vault_keys`

---

### 🏢 MODE 2: Advanced Enterprise (`enterprise`)
> **Hardware:** 28 Containers | ~8 GB RAM  
> **Command:** `.\scripts\start-lab.ps1 -Mode enterprise`  
> **Focus:** Includes **EVERYTHING in Mode 1** + Dual ISP BGP, DDoS Scrubbing, WireGuard ZTNA, VoIP PBX, CCTV RTSP, IoT MQTT, NAC 802.1X, Spine-Leaf Fabric & Branch SD-WAN.

#### 🌐 1. New Browser Web Applications (Mode 1 এর সাথে নতুন যুক্ত হবে)
| Application | URL | Role & Description | Default Credentials |
|:---|:---|:---|:---|
| **Grafana NMS Dashboard** | [`http://localhost:3000`](http://localhost:3000) | Real-time network telemetry, switch load, Prometheus metrics, and bandwidth monitor. | `nexus_nms_admin` / `NMS@Nexus2026!` *(Anonymous Viewer enabled)* |
| **DDoS Scrubbing Center** | [`http://localhost:8080`](http://localhost:8080) | Nginx traffic rate-limiting and DDoS mitigation proxy (simulates Cloudflare / Akamai). | *Public proxy endpoint* |
| **CCTV Camera Web Player** | [`http://localhost:8888`](http://localhost:8888) | Live in-browser HLS video surveillance player streaming from campus cameras. | *No password required* |
| **MinIO DR Backup SAN** | [`http://localhost:9003`](http://localhost:9003) | Disaster recovery secondary backup vault console. | `nexus_dr_admin` / `DRBackup_Nexus@2026!` |

#### 🔌 2. New Network Protocols & Dedicated Services
| Service | Access Command / Method | Port / Protocol | Details |
|:---|:---|:---|:---|
| **Asterisk VoIP PBX** | Connect via Softphone (Zoiper/Linphone) or `svcrack` | Port `5060` (SIP UDP/TCP) | Exts: `1001`, `1002`, `1003` (Pass: `1234`)<br>Conference Room: `9000` *(Eavesdropping)* |
| **CCTV RTSP Video Stream** | Open in VLC: `rtsp://localhost:8554/nexus-lobby`<br>or `rtsp://localhost:8554/nexus-serverroom` | Port `8554` (RTSP) | Unauthenticated live surveillance camera feeds |
| **Campus IoT MQTT Broker** | `mosquitto_sub -h localhost -p 1883 -t '#'` | Port `1883` (MQTT) | Unauthenticated broker leaking DC IP alerts |
| **NAC ISE Server (802.1X)** | `curl http://10.0.2.15:8100/api/bypass` | Port `8100` (HTTP API) | Cisco ISE simulation (Vulnerable to MAC Bypass) |
| **WireGuard ZTNA Gateway** | WireGuard client on port `51820/udp` | Port `51820` (UDP), `8443` | Encrypted Zero-Trust remote worker VPN |
| **DC Spine-Leaf Fabric** | 4 Switch containers (`dc-spine-1/2`, `dc-leaf-1/2`) | BGP-EVPN / VXLAN | Non-blocking 100GbE Data Center switching fabric |

#### 💻 3. New Branch Office Workstation
```bash
# Dhaka Regional Branch Employee PC (ibrahim) — contains WireGuard config & key leak:
docker exec -it nexus-branch-pc-01 bash   # Credentials: ibrahim / Branch@2026
```

#### 🚩 4. New CTF Flag in Mode 2
- 🟢 **Flag 6 (NAC Bypass):** `FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}` — Found on NAC Server `/api/bypass`

---

### ☁️ MODE 3: Full Hybrid Cloud (`all`)
> **Hardware:** 33 Containers | ~12 GB RAM  
> **Command:** `.\scripts\start-lab.ps1 -Mode all`  
> **Focus:** Includes **EVERYTHING in Mode 1 & 2** + AWS/Azure Cloud VPC Peering, Transit Gateway, Cloud Load Balancer, SSRF-vulnerable Microservices, Cloud RDS PostgreSQL, and SaaS SSO.

#### 🌐 1. New Cloud Browser Web Applications (Mode 1 & 2 এর সাথে নতুন যুক্ত হবে)
| Application | URL | Role & Description | Default Credentials |
|:---|:---|:---|:---|
| **Cloud Microservice API** | [`http://localhost:8090`](http://localhost:8090) | Kubernetes-style cloud microservice API. Vulnerable to Server-Side Request Forgery (`/api/v1/fetch?url=`). | Endpoints: `/api/v1/config`, `/api/v1/health` |
| **SaaS SSO Identity Portal** | [`https://localhost:8443`](https://localhost:8443) | Corporate SAML/OAuth2 Single Sign-On Identity Portal. Target for auth bypass. | Use corporate employee domain credentials |

#### 🔌 2. New Cloud Infrastructure Services
| Service | Access / Role | Subnet / IP | Details |
|:---|:---|:---|:---|
| **Cloud Transit Gateway** | AWS TGW / Azure VNet Peering | `172.16.0.1` / `10.0.3.251` | Secure peering bridge between on-prem Data Center and Cloud VPC |
| **Cloud Load Balancer** | HAProxy Application Load Balancer | `172.16.0.10` | Distributes cloud traffic to microservice pods |
| **Cloud Managed RDS DB** | PostgreSQL Cloud Database | `172.16.0.30:5432` | User: `nexus_rds_admin`<br>Pass: `RdsNexusProd@2026!Cloud` (DB: `nexus_cloud_prod`) |

#### 🚩 3. New CTF Flags in Mode 3
- 🔴 **Flag 4 (Cloud SSRF):** `FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}` — Found in Cloud Microservice `/api/v1/secrets`
- 🟡 **Flag 5 (SaaS SSO):** `FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}` — Found in SaaS SSO `/dashboard`

---

## 📊 Mode Comparison Matrix (একনজরে সব মোড)

| Feature / Service | Mode 1: `core` (13) | Mode 2: `enterprise` (28) | Mode 3: `all` (33) |
|:---|:---:|:---:|:---:|
| **Corporate Web Portal (`:80`)** | ✅ Active | ✅ Active | ✅ Active |
| **MailHog Webmail (`:8025`)** | ✅ Active | ✅ Active | ✅ Active |
| **MinIO Primary Storage (`:9001`)** | ✅ Active | ✅ Active | ✅ Active |
| **SSH Bastion (`:2222`)** | ✅ Active | ✅ Active | ✅ Active |
| **PostgreSQL Crown Jewels DB** | ✅ Active | ✅ Active | ✅ Active |
| **Active Directory Samba4 DC** | ✅ Active | ✅ Active | ✅ Active |
| **DevOps & HR Workstations** | ✅ Active | ✅ Active | ✅ Active |
| **Grafana NMS Telemetry (`:3000`)** | ❌ Off | ✅ Active | ✅ Active |
| **DDoS Scrubbing Proxy (`:8080`)** | ❌ Off | ✅ Active | ✅ Active |
| **CCTV Camera Web & RTSP (`:8888`, `:8554`)** | ❌ Off | ✅ Active | ✅ Active |
| **Asterisk VoIP PBX (`:5060`)** | ❌ Off | ✅ Active | ✅ Active |
| **Campus IoT MQTT Broker (`:1883`)** | ❌ Off | ✅ Active | ✅ Active |
| **NAC ISE Server (`:8100`)** | ❌ Off | ✅ Active | ✅ Active |
| **Spine-Leaf Fabric & Branch SD-WAN** | ❌ Off | ✅ Active | ✅ Active |
| **Cloud Microservice API (`:8090`)** | ❌ Off | ❌ Off | ✅ Active |
| **SaaS SSO Identity Portal (`:8443`)** | ❌ Off | ❌ Off | ✅ Active |
| **Cloud Transit Gateway & RDS DB** | ❌ Off | ❌ Off | ✅ Active |
| **CTF Flags Available** | Flags 1, 2, 3 | Flags 1, 2, 3, 6 | Flags 1 to 6 (All) |

---

## 🛠️ File Locations for Future Customization (কোড বা কনফিগ মডিফাই করতে চাইলে)

| Component | File Path | What You Can Modify |
|:---|:---|:---|
| **Corporate Web Portal App** | [`lab/apps/corp-web/`](./lab/apps/corp-web/) | Flask Python code, HTML templates, SQL queries, CTF flags |
| **Internal ERP Financial App** | [`lab/apps/internal-erp/`](./lab/apps/internal-erp/) | ERP payroll portal logic & DB connections |
| **Cloud Microservice App** | [`lab/config/cloud-tier/cloud-app/`](./lab/config/cloud-tier/cloud-app/) | SSRF endpoints & JWT authentication logic |
| **SaaS SSO Portal App** | [`lab/config/cloud-tier/saas-mock/`](./lab/config/cloud-tier/saas-mock/) | SAML/OAuth2 login pages & credential rules |
| **Nginx WAF Proxy** | [`lab/config/nginx-waf/nginx.conf`](./lab/config/nginx-waf/nginx.conf) | Reverse proxy routing & rate limiting |
| **PostgreSQL Database** | [`lab/config/database/init.sql`](./lab/config/database/init.sql) | Initial tables, sample financial data & crown jewel keys |
| **Firewall iptables** | [`lab/config/hq-firewall/`](./lab/config/hq-firewall/) | Inter-VLAN routing, drop/accept rules, NAT |
| **VoIP Asterisk PBX** | [`lab/config/voip/`](./lab/config/voip/) | SIP user accounts, extensions & conference rooms |
| **Prometheus Metrics** | [`lab/config/nms/prometheus.yml`](./lab/config/nms/prometheus.yml) | Scrape intervals and target hostnames |
| **Master Compose Blueprint** | [`lab/docker-compose.yml`](./lab/docker-compose.yml) | Subnet IP allocations, port forwards & container profiles |

> **💡 Quick Hot-Reload Tip:**  
> কোনো ফাইল এডিট করার পর পুরো ল্যাব বন্ধ না করে শুধু ওই কন্টেইনারটি রিস্টার্ট করুন:  
> `docker compose restart <container-name>` *(e.g. `docker compose restart corp-web-portal`)*

---

## 🔧 Troubleshooting & FAQ

- **Q: `check-health.ps1` এ কিছু কন্টেইনার gray (not deployed) দেখাচ্ছে কেন?**  
  **A:** এটি সম্পূর্ণ স্বাভাবিক। আপনি যদি `core` মোড চালু করেন, তবে Enterprise ও Cloud কন্টেইনারগুলো বন্ধ থাকবে। সবগুলো একসাথে চালাতে `.\scripts\start-lab.ps1 -Mode all` ব্যবহার করুন।
- **Q: পোর্টে কনফ্লিক্ট দেখালে কী করব? (e.g. Port 80 already in use)**  
  **A:** `netstat -ano | findstr :80` দিয়ে চেক করুন আপনার সিস্টেমে IIS বা অন্য কোনো ওয়েব সার্ভার পোর্ট 80 দখল করে রেখেছে কিনা।
- **Q: WireGuard বা ZTNA কন্টেইনারে এরর দিলে কী করব?**  
  **A:** Windows ব্যবহারকারীদের WSL2 ব্যাকএন্ড নিশ্চিত করতে হবে (`wsl --set-default-version 2`)।

---

> 🔒 **Educational Notice:** This lab is strictly intended for educational, cybersecurity training, and defensive research. All vulnerabilities are contained within isolated Docker bridge networks.
