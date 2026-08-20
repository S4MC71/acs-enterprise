# 🏢 Nexus Global Enterprise — Penetration Testing & Network Architecture Lab

> **A realistic Docker-based Large Enterprise Network simulation (33 containers across 9 segregated subnets).**  
> 🗺️ **Interactive Architecture Map:** Open [**`enterprise-network.html`**](./enterprise-network.html) in your browser for real-time Pan/Zoom and Node Inspection.

---

## 📑 Table of Contents
1. [⚙️ 1. Prerequisites & Scratch Installation](#-1-prerequisites--scratch-installation)
   - [Windows (Docker + WSL2)](#windows-setup)
   - [Linux (Docker Engine)](#linux-setup)
   - [macOS (Docker Desktop)](#macos-setup)
2. [📥 2. Clone & Build Lab](#-2-clone--build-lab)
3. [🚀 3. Starting the Lab (3 Modes)](#-3-starting-the-lab-3-modes)
4. [🔍 4. Health Check & Verification](#-4-health-check--verification)
5. [🌐 5. Mode-by-Mode Service Directory](#-5-mode-by-mode-service-directory)
   - [Mode 1: Standard Infrastructure (`core` — 13 Nodes)](#mode-1-standard-infrastructure-core--13-nodes)
   - [Mode 2: Advanced Enterprise (`enterprise` — 28 Nodes)](#mode-2-advanced-enterprise-enterprise--28-nodes)
   - [Mode 3: Full Hybrid Cloud (`all` — 33 Nodes)](#mode-3-full-hybrid-cloud-all--33-nodes)
6. [💻 6. Gray-Box Workstation Shell Access](#-6-gray-box-workstation-shell-access)
7. [🚩 7. CTF Flags Reference](#-7-ctf-flags-reference)
8. [🧹 8. Lifecycle Management & Total Factory Cleanup](#-8-lifecycle-management--total-factory-cleanup)
   - [A. Soft Stop](#a-soft-stop-preserves-data)
   - [B. Reset Lab](#b-reset-lab-wipes-data-retains-images)
   - [C. Nuclear Factory Cleanup (As if never installed)](#c-nuclear-factory-cleanup-total-wipe)
   - [D. Fresh Re-Install](#d-fresh-re-install)
9. [🛠️ 9. Customization & File Map](#-9-customization--file-map)
10. [🔧 10. Troubleshooting](#-10-troubleshooting)

---

## ⚙️ 1. Prerequisites & Scratch Installation

If you do not have Docker or Git installed on your system yet, follow the setup for your OS:

### Windows Setup
1. **Install Git:** Download & install from [git-scm.com](https://git-scm.com/).
2. **Enable WSL2 (Required for WireGuard/ZTNA):**  
   Open PowerShell as Administrator and run:
   ```powershell
   wsl --install
   wsl --set-default-version 2
   ```
3. **Install Docker Desktop:**  
   Download & install [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop/).  
   *During installation, ensure **"Use WSL 2 instead of Hyper-V"** is checked.*
4. Start Docker Desktop and ensure it is running.

### Linux Setup
```bash
# 1. Install Docker Engine & Compose plugin:
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Add your user to the docker group:
sudo usermod -aG docker $USER
newgrp docker

# 3. Verify installation:
docker compose version
```

### macOS Setup
1. Install [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop/) (Apple Silicon or Intel).
2. Install Git: `xcode-select --install` or via Homebrew (`brew install git`).

---

## 📥 2. Clone & Build Lab

```bash
# 1. Clone the repository:
git clone https://github.com/S4MC71/acs-enterprise.git

# 2. Navigate to the lab folder:
cd acs-enterprise/lab

# 3. (Optional) Pre-build or pull all container images:
docker compose --profile core --profile enterprise --profile cloud build
```

---

## 🚀 3. Starting the Lab (3 Modes)

Choose your desired operational mode based on your system RAM:

### Windows (PowerShell)
```powershell
# Interactive Menu (prompts you to pick mode):
.\scripts\start-lab.ps1

# Or launch directly by mode:
.\scripts\start-lab.ps1 -Mode core          # 🛡️ Mode 1: Standard Lab (13 containers, ~4GB RAM)
.\scripts\start-lab.ps1 -Mode enterprise    # 🏢 Mode 2: Advanced Enterprise (28 containers, ~8GB RAM)
.\scripts\start-lab.ps1 -Mode all           # ☁️ Mode 3: Full Hybrid Cloud (33 containers, ~12GB RAM)
```

### Linux / macOS (Bash)
```bash
chmod +x scripts/*.sh

# Using the interactive script:
./scripts/start-lab.sh

# Or using native Docker Compose commands:
docker compose --profile core up -d                                      # Mode 1
docker compose --profile core --profile enterprise up -d                 # Mode 2
docker compose --profile core --profile enterprise --profile cloud up -d # Mode 3
```

---

## 🔍 4. Health Check & Verification

Run the built-in diagnostic tool to verify the status of all 33 containers:

```powershell
# Windows:
.\scripts\check-health.ps1

# Linux / macOS:
./scripts/check-health.sh
```

**Status Indicators:**
- 🟢 **Green (`✓`):** Container is active, healthy, and accessible.
- ⚪ **Dark Gray (`○`):** Container is not deployed in current mode (expected behavior).
- 🔴 **Red (`✗`):** Container crashed or failed to start.

Quick CLI verification:
```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

---

## 🌐 5. Mode-by-Mode Service Directory

---

### Mode 1: Standard Infrastructure (`core` — 13 Nodes)
> **Hardware:** 13 Containers | ~4 GB RAM | **Command:** `start-lab.ps1 -Mode core`  
> **Scope:** Edge BGP Router, NGFW, DMZ Web Services, Core Active Directory, SIEM, Data Center Database & SAN, Campus Workstations.

#### 🌐 Browser Web Applications
| Application | URL | Role | Default Credentials |
|:---|:---|:---|:---|
| **Corporate Web Portal** | [`http://localhost:80`](http://localhost:80) | Flask Shipment Portal (behind WAF). Contains SQLi & CMDi. | `admin` / `NexusTechAdmin2026!` |
| **MailHog Webmail** | [`http://localhost:8025`](http://localhost:8025) | Captures corporate emails and password reset tokens. | *No auth required* |
| **MinIO Primary SAN** | [`http://localhost:9001`](http://localhost:9001) | S3-compatible primary storage console. | `nexus_san_root` / `SuperS3cUr3_B4ckup_Vault_Pass_2026!` |

#### 🔌 CLI & Protocol Services
| Service | Command / Connection | Port | Description |
|:---|:---|:---|:---|
| **SSH Bastion Jump Host** | `ssh devops-remote@localhost -p 2222` | `2222` (SSH) | Password: `devops-remote@123` *(Pivot into Core & Campus)* |
| **PostgreSQL Crown Jewels** | `docker exec -it nexus-dc-prod-database psql -U nexus_admin -d nexus_prod` | `5432` | `nexus_admin` / `Nexu$$Prod2026!Sec` *(Contains Flag 3)* |
| **Active Directory DC** | `smbclient -L //10.0.2.10 -N` | `445`, `389` | `Administrator` / `NexusAD2026!Admin` *(SMB shares)* |
| **SIEM / SOC Collector** | `docker exec -it nexus-corp-siem-soc bash` | `514` | Blue-Team logs: `tail -f /var/log/nexus-syslog/nexus-all.log` |
| **Internal ERP Intranet** | `http://10.0.3.10:8000` *(Internal DC)* | `8000` | Internal financial & payroll records |

#### 🚩 CTF Flags in Mode 1
- 🟢 **Flag 1 (SQLi):** `FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026}` — Web Portal `/?track_id=`
- 🟡 **Flag 2 (CMDi):** `FLAG{CMD_INJ3CT10N_PORTAL_COMPR0M1S3D}` — Web Admin `/admin/server-check`
- 🔴 **Flag 3 (Crown Jewels):** `FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}` — DB `system_vault_keys`

---

### Mode 2: Advanced Enterprise (`enterprise` — 28 Nodes)
> **Hardware:** 28 Containers | ~8 GB RAM | **Command:** `start-lab.ps1 -Mode enterprise`  
> **Scope:** **Everything in Mode 1 +** Dual ISP BGP, DDoS Proxy, WireGuard ZTNA, VoIP PBX, CCTV RTSP, IoT MQTT, NAC 802.1X, Spine-Leaf Fabric & Branch SD-WAN.

#### 🌐 Additional Browser Web Applications
| Application | URL | Role | Default Credentials |
|:---|:---|:---|:---|
| **Grafana NMS Dashboard** | [`http://localhost:3000`](http://localhost:3000) | Real-time network telemetry, switch metrics & traffic monitor. | `nexus_nms_admin` / `NMS@Nexus2026!` *(Anonymous Viewer enabled)* |
| **DDoS Scrubbing Center** | [`http://localhost:8080`](http://localhost:8080) | Nginx traffic rate-limiting & DDoS mitigation proxy. | *Public proxy endpoint* |
| **CCTV Camera Web Player** | [`http://localhost:8888`](http://localhost:8888) | Live in-browser HLS video surveillance player. | *No auth required* |
| **MinIO DR Backup SAN** | [`http://localhost:9003`](http://localhost:9003) | Disaster recovery secondary backup vault console. | `nexus_dr_admin` / `DRBackup_Nexus@2026!` |

#### 🔌 Additional Protocol Services
| Service | Command / Connection | Port | Description |
|:---|:---|:---|:---|
| **Asterisk VoIP PBX** | Softphone (Zoiper/Linphone) or `svcrack` | `5060` (SIP) | Exts: `1001`, `1002`, `1003` (Pass: `1234`), Conf: `9000` |
| **CCTV RTSP Stream** | VLC Player: `rtsp://localhost:8554/nexus-lobby` | `8554` (RTSP) | Unauthenticated live video feed |
| **Campus IoT MQTT** | `mosquitto_sub -h localhost -p 1883 -t '#'` | `1883` (MQTT) | Unauthenticated broker leaking DC IP alerts |
| **NAC ISE Server** | `curl http://10.0.2.15:8100/api/bypass` | `8100` (HTTP) | Cisco ISE simulation (Vulnerable to MAC Bypass) |
| **WireGuard ZTNA** | WireGuard client on port `51820/udp` | `51820`, `8443` | Encrypted Zero-Trust remote worker VPN |
| **Spine-Leaf Fabric** | 4 Switch containers (`dc-spine-1/2`, `dc-leaf-1/2`) | BGP-EVPN | High-speed Data Center switching fabric |

#### 🚩 Additional CTF Flag in Mode 2
- 🟢 **Flag 6 (NAC Bypass):** `FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}` — NAC Server `/api/bypass`

---

### Mode 3: Full Hybrid Cloud (`all` — 33 Nodes)
> **Hardware:** 33 Containers | ~12 GB RAM | **Command:** `start-lab.ps1 -Mode all`  
> **Scope:** **Everything in Mode 1 & 2 +** AWS/Azure Cloud VPC Peering, Transit Gateway, Cloud ALB, Cloud SSRF Microservices, Cloud RDS PostgreSQL & SaaS SSO.

#### 🌐 Additional Cloud Web Applications
| Application | URL | Role | Default Credentials |
|:---|:---|:---|:---|
| **Cloud Microservice API** | [`http://localhost:8090`](http://localhost:8090) | Cloud microservice API. Vulnerable to SSRF (`/api/v1/fetch?url=`). | Endpoints: `/api/v1/config`, `/api/v1/health` |
| **SaaS SSO Identity Portal** | [`https://localhost:8443`](https://localhost:8443) | Corporate SAML/OAuth2 Single Sign-On Portal. Target for auth bypass. | Use employee domain credentials |

#### 🔌 Additional Cloud Infrastructure
| Service | Access / Role | Subnet / IP | Description |
|:---|:---|:---|:---|
| **Cloud Transit Gateway** | AWS TGW / Azure VNet Peering | `172.16.0.1` / `10.0.3.251` | Secure peering bridge between on-prem DC and Cloud VPC |
| **Cloud Load Balancer** | HAProxy Application Load Balancer | `172.16.0.10` | Distributes cloud traffic to microservice pods |
| **Cloud Managed RDS DB** | PostgreSQL Cloud Database | `172.16.0.30:5432` | `nexus_rds_admin` / `RdsNexusProd@2026!Cloud` |

#### 🚩 Additional CTF Flags in Mode 3
- 🔴 **Flag 4 (Cloud SSRF):** `FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}` — Cloud App `/api/v1/secrets`
- 🟡 **Flag 5 (SaaS SSO):** `FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}` — SaaS SSO `/dashboard`

---

## 💻 6. Gray-Box Workstation Shell Access

Access compromised employee workstations directly inside the lab environment:

```bash
# 1. DevOps Workstation (tahmed) — has Docker access, git history, SSH keys:
docker exec -it nexus-pc-dev-01 bash
# Credentials: tahmed / DevOpsP@ss2026!

# 2. HR Director Workstation (sjenkins) — contains employee rosters & salary docs:
docker exec -it nexus-pc-hr-01 bash
# Credentials: sjenkins / HrDirector9921!

# 3. Dhaka Branch Employee PC (ibrahim) — contains WireGuard VPN key leak:
docker exec -it nexus-branch-pc-01 bash
# Credentials: ibrahim / Branch@2026

# 4. Blue-Team / SOC SIEM Box (Live security event monitoring):
docker exec -it nexus-corp-siem-soc bash
# tail -f /var/log/nexus-syslog/nexus-all.log
```

---

## 🚩 7. CTF Flags Reference

| # | Mode | Difficulty | Vulnerability / Attack Path | Target Component | Flag Value |
|:---:|:---:|:---:|:---|:---|:---|
| **1** | Core | 🟢 Easy | SQL Injection on `/?track_id=` | Corporate Web Portal (`10.0.1.20`) | `FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026}` |
| **2** | Core | 🟡 Medium | Command Injection in Ping Tool | Web Admin (`/admin/server-check`) | `FLAG{CMD_INJ3CT10N_PORTAL_COMPR0M1S3D}` |
| **3** | Core | 🔴 Hard | DB Crown Jewels (`system_vault_keys`) | Production DB (`10.0.3.20`) | `FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}` |
| **4** | Cloud | 🔴 Hard | Cloud SSRF via `/api/v1/fetch?url=` | Cloud Microservice (`172.16.0.20:8090`) | `FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}` |
| **5** | Cloud | 🟡 Medium | SaaS SSO Auth Bypass | SaaS SSO Portal (`172.16.0.40:8443`) | `FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}` |
| **6** | Enterprise | 🟢 Easy | NAC MAC Authentication Bypass | NAC Server (`10.0.2.15:8100`) | `FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}` |

---

## 🧹 8. Lifecycle Management & Total Factory Cleanup

### A. Soft Stop (Preserves Data)
```bash
docker compose --profile core --profile enterprise --profile cloud stop
# Or:
docker compose --profile core --profile enterprise --profile cloud down
```

### B. Reset Lab (Wipes Data & Flags, Retains Built Images)
```powershell
# Windows:
.\scripts\reset-lab.ps1

# Linux / macOS:
./scripts/reset-lab.sh
```

### C. Nuclear Factory Cleanup (Total Wipe — As if Never Installed)
To completely delete **all containers, volumes, networks, and build caches** from your machine:

**Windows (PowerShell):**
```powershell
# 1. Force remove all lab containers, networks, and persistent volumes:
docker compose --profile core --profile enterprise --profile cloud down -v --remove-orphans

# 2. Delete all built lab images:
docker images --filter "reference=*nexus*" -q | ForEach-Object { docker rmi -f $_ }
docker images --filter "reference=*lab*" -q | ForEach-Object { docker rmi -f $_ }

# 3. Clean all build cache and dangling data:
docker builder prune -af
docker volume prune -f
docker network prune -f
```

**Linux / macOS (Bash):**
```bash
# 1. Force remove all lab containers, networks, and persistent volumes:
docker compose --profile core --profile enterprise --profile cloud down -v --remove-orphans

# 2. Delete all built lab images:
docker images | grep -E "nexus|lab-" | awk '{print $3}' | xargs -r docker rmi -f

# 3. Clean all build cache and dangling data:
docker builder prune -af
docker volume prune -f
docker network prune -f
```

### D. Fresh Re-Install
After a total wipe, recreate everything cleanly in one step:
```powershell
# Rebuild and start from scratch:
.\scripts\start-lab.ps1 -Mode all
```

---

## 🛠️ 9. Customization & File Map

| Component | Source / Config Path | What You Can Modify |
|:---|:---|:---|
| **Web Portal App** | [`lab/apps/corp-web/`](./lab/apps/corp-web/) | Flask routes, HTML UI, SQL queries, CTF flags |
| **ERP Intranet App** | [`lab/apps/internal-erp/`](./lab/apps/internal-erp/) | Internal employee payroll & DB queries |
| **Cloud Microservice** | [`lab/config/cloud-tier/cloud-app/`](./lab/config/cloud-tier/cloud-app/) | SSRF endpoints & JWT verification keys |
| **SaaS SSO Portal** | [`lab/config/cloud-tier/saas-mock/`](./lab/config/cloud-tier/saas-mock/) | SAML/OAuth2 login pages & mock users |
| **Nginx WAF Proxy** | [`lab/config/nginx-waf/nginx.conf`](./lab/config/nginx-waf/nginx.conf) | Rate limits, reverse proxy routing, headers |
| **PostgreSQL Database** | [`lab/config/database/init.sql`](./lab/config/database/init.sql) | Initial tables, sample financial data, crown jewel flags |
| **Firewall iptables** | [`lab/config/hq-firewall/`](./lab/config/hq-firewall/) | Inter-VLAN packet filtering, NAT & drop rules |
| **Asterisk VoIP PBX** | [`lab/config/voip/`](./lab/config/voip/) | SIP users, dialplans & conference room configs |
| **Prometheus NMS** | [`lab/config/nms/prometheus.yml`](./lab/config/nms/prometheus.yml) | Scrape metrics & target container IPs |
| **Master Compose** | [`lab/docker-compose.yml`](./lab/docker-compose.yml) | Subnet definitions, exposed ports & profiles |

> **💡 Hot-Reload Tip:** After editing any file, apply changes instantly without stopping the entire lab:  
> `docker compose restart <container-name>` *(e.g. `docker compose restart corp-web-portal`)*

---

## 🔧 10. Troubleshooting

- **`check-health.ps1` shows gray `○` status:**  
  *Normal behavior.* Gray indicates containers not included in your chosen profile. Use `-Mode all` to run all 33 containers.
- **Port Conflict (e.g. Port 80 already in use):**  
  Check conflicting processes: `netstat -ano | findstr :80` (Windows) or `sudo lsof -i :80` (Linux). Stop local IIS / Apache / Nginx if running.
- **WireGuard / ZTNA container error on Windows:**  
  Ensure WSL2 is the default backend: `wsl --set-default-version 2`.
- **Low RAM Warning:**  
  If your PC has ≤ 8 GB RAM, stick to **Mode 1 (`core`)** for smooth performance.

---

> 🔒 **Educational Notice:** This lab is strictly intended for educational, cybersecurity training, and defensive research. All vulnerabilities are isolated inside virtual Docker bridge networks.
