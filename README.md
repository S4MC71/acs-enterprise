# 🏢 Nexus Global Enterprise — Penetration Testing Lab

> **A fully realistic, Docker-based Large Enterprise Network simulation for cybersecurity education and penetration testing practice.**

Based on the **Large Enterprise Network** architecture (`enterprise-network.html`), this lab simulates a real corporate environment with 33 containers across 9 network zones — supporting Black-Box, Gray-Box, and White-Box testing scenarios.

---

## 📋 Requirements

### System Requirements

| Mode | Containers | Minimum RAM | Recommended RAM |
|:---|:---|:---|:---|
| Standard Lab (core) | 14 | 4 GB free | 6 GB |
| Large Enterprise | 28 | 8 GB free | 12 GB |
| Full (all profiles) | 33 | 10 GB free | 16 GB |

### Software Requirements

| Tool | Version | Notes |
|:---|:---|:---|
| **Docker Desktop** | 4.x+ | Windows / macOS / Linux |
| **Docker Compose** | v2.x+ | Bundled with Docker Desktop |
| **Git** | Any | To clone the repository |
| **PowerShell** | 5.1+ (Windows) or 7+ | For `.ps1` scripts |
| **WSL2** (Windows only) | Enabled | Required for WireGuard/ZTNA containers |

> ⚠️ **WSL2 Required on Windows** for the `enterprise` profile — needed by WireGuard-based ZTNA and Branch SD-WAN containers. Enable it via: `wsl --install`

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/S4MC71/acs-enterprise.git
cd acs-enterprise/lab
```

### 2. Start the Lab (Windows)

```powershell
# Interactive mode — shows a menu to select lab size
.\scripts\start-lab.ps1

# Or specify mode directly:
.\scripts\start-lab.ps1 -Mode core          # Standard Lab (~4GB RAM)
.\scripts\start-lab.ps1 -Mode enterprise    # Large Enterprise (~8GB RAM)
.\scripts\start-lab.ps1 -Mode all           # Full Lab with Cloud (~12GB RAM)
```

### 3. Start the Lab (Linux / macOS)

```bash
chmod +x scripts/start-lab.sh
./scripts/start-lab.sh
```

### 4. Verify All Containers are Running

```powershell
.\scripts\check-health.ps1
```

### 5. Stop the Lab

```powershell
# Stop all profiles (preserves data volumes)
docker compose --profile core --profile enterprise --profile cloud down

# Full reset — removes ALL containers, networks, and volumes
.\scripts\reset-lab.ps1
```

---

## 🌐 Network Architecture

```
[Internet / WAN]
  198.51.100.0/24  — ISP1 (Primary)
  203.0.113.0/24   — ISP2 (Secondary / Failover)
         │
  DDoS Scrubbing Center ──→ Dual BGP Edge Routers
         │
[DMZ — 10.0.1.0/24]
  10.0.1.10   Nginx WAF / Reverse Proxy  (port 80 → host)
  10.0.1.20   Corporate Web Portal       (Flask — login required)
  10.0.1.30   Email Server (MailHog)     (port 8025 → host)
  10.0.1.40   SSH Bastion / Jump Host    (port 2222 → host)
  10.0.1.50   ZTNA / VPN Gateway         (WireGuard + ZTNA portal)
         │
[Core Backbone — 10.0.2.0/24]
  10.0.2.10   Active Directory DC        (Samba4 / SMB / LDAP)
  10.0.2.15   NAC Server (ISE/ClearPass) (port 8100)
  10.0.2.20   Prometheus NMS
  10.0.2.21   Grafana Dashboard          (port 3000 → host)
  10.0.2.99   SIEM / Syslog Collector
         │
[Data Center — 10.0.3.0/24]
  10.0.3.10   ERP Intranet               (port 8000)
  10.0.3.20   PostgreSQL DB              (CROWN JEWELS)
  10.0.3.30   MinIO SAN Primary          (port 9001)
  10.0.3.35   MinIO SAN DR/Backup
  10.0.3.241  DC Spine Switch 1
  10.0.3.242  DC Spine Switch 2
  10.0.3.243  DC Leaf Switch 1
  10.0.3.244  DC Leaf Switch 2
         │
[Campus — 10.0.4.0/24]
  10.0.4.10   HR Workstation             (sjenkins)
  10.0.4.20   DevOps Workstation         (tahmed)
  10.0.4.50   VoIP PBX (Asterisk)       (SIP port 5060)
  10.0.4.60   IP Camera Server (RTSP)   (port 8554 / 8888)
  10.0.4.70   IoT Device (MQTT)         (port 1883)
         │
[Branch Office — 10.0.5.0/24]
  10.0.5.1    Branch SD-WAN Edge
  10.0.5.10   Branch Employee PC         (ibrahim)

[Cloud Tier — 172.16.0.0/24]  (--profile cloud)
  172.16.0.1   Cloud Transit Gateway
  172.16.0.10  Cloud Load Balancer (HAProxy)
  172.16.0.20  Cloud Microservice (SSRF vuln)  (port 8090 → host)
  172.16.0.30  Cloud DB (PostgreSQL RDS sim)
  172.16.0.40  SaaS SSO Portal (SAML/OAuth2)   (port 8443 → host)
```

---

## 🔑 Access Points & Credentials

### Web Interfaces (access from browser)

| URL | Description | Credentials |
|:---|:---|:---|
| `http://localhost:80` | Corporate Web Portal | `admin` / `NexusTechAdmin2026!` |
| `http://localhost:8025` | Corporate Webmail (MailHog) | None required |
| `http://localhost:3000` | Grafana NMS Dashboard | `nexus_nms_admin` / `NMS@Nexus2026!` |
| `http://localhost:8090` | Cloud Microservice API | None (JWT required for some endpoints) |
| `http://localhost:8443` | SaaS SSO Portal | Domain credentials |
| `http://localhost:8888` | IP Camera HLS Stream | None (unauthenticated) |
| `http://localhost:9001` | MinIO SAN Console | `nexus_san_root` / `SuperS3cUr3_B4ckup_Vault_Pass_2026!` |

### SSH / Container Access

```bash
# Pentest Box (Black-Box entry)
# Use your own local Kali Linux / WSL environment
# See docs/attacker_tools_guide.md for setup

# SSH Bastion (from host)
ssh devops-remote@localhost -p 2222
# Password: devops-remote@123

# DevOps Workstation (Gray-Box entry)
docker exec -it nexus-pc-dev-01 bash
# User: tahmed | Password: DevOpsP@ss2026!

# HR Workstation (Gray-Box entry)
docker exec -it nexus-pc-hr-01 bash
# User: sjenkins | Password: HrDirector9921!

# Branch PC
docker exec -it nexus-branch-pc-01 bash
# User: ibrahim | Password: Branch@2026

# Blue-Team / SIEM Analysis
docker exec -it nexus-corp-siem-soc bash
# tail -f /var/log/nexus-syslog/nexus-all.log
```

### RTSP Camera Streams

```bash
# View via VLC: Media > Open Network Stream
rtsp://localhost:8554/nexus-lobby         # Lobby Camera
rtsp://localhost:8554/nexus-serverroom   # Server Room Camera

# HLS (browser)
http://localhost:8888/nexus-lobby/index.m3u8
```

### VoIP / SIP

```
PBX: localhost:5060 (UDP/TCP)
Extension 1003 — Tanvir Ahmed (weak password: 1234)  ← brute-force target
```

### MQTT IoT

```bash
# Subscribe to all topics (from pentest box)
mosquitto_sub -h 10.0.4.70 -t '#' -v
```

---

## 🎯 Pentesting Modes

### Black-Box (No prior knowledge)
Read `docs/attacker_tools_guide.md` to setup your environment.
```bash
# From your own pentest machine:
nmap -sS -sV -p 80,22,8025 198.51.100.10
```

### Gray-Box (Limited knowledge)
```bash
# DevOps role — knows some internal IPs
docker exec -it nexus-pc-dev-01 bash

# HR role — finds credentials in documents
docker exec -it nexus-pc-hr-01 bash
```

### White-Box / Blue-Team (Full visibility)
```bash
docker exec -it nexus-corp-siem-soc bash
tail -f /var/log/nexus-syslog/nexus-all.log
cat /var/log/nexus-alerts/firewall-blocks.log
cat /var/log/nexus-alerts/auth-failures.log
```

---

## 🚩 CTF Flags (6 Total)

| # | Difficulty | Attack Path | Flag |
|:---|:---|:---|:---|
| 1 | 🟢 Easy | SQL Injection on `/?track_id=` | `FLAG{SQL_1NJ3CT10N_DMZ_W3B_PORTAL_2026}` |
| 2 | 🟡 Medium | Command Injection in Ping Tool | `FLAG{CMD_INJ3CT10N_PORTAL_COMPR0M1S3D}` |
| 3 | 🔴 Hard | PostgreSQL DB → `system_vault_keys` | `FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}` |
| 4 | 🔴 Hard | Cloud SSRF → `/api/v1/secrets` | `FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}` |
| 5 | 🟡 Medium | SaaS SSO credential stuffing | `FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}` |
| 6 | 🟢 Easy | NAC MAC bypass `/api/bypass` | `FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}` |

---

## 📁 Project Structure

```
acs-enterprise/
├── README.md                       # Main repository README
├── enterprise-network.html         # Architecture diagram (do not modify)
├── AI_AGENT_CONTEXT.md             # AI agent handover context
└── lab/
    ├── README.md                   # Lab specific documentation
    ├── docker-compose.yml          # 33 containers, 3 profiles, 9 subnets
    ├── scripts/
    │   ├── start-lab.ps1           # Windows launcher (interactive menu)
    │   ├── start-lab.sh            # Linux/macOS launcher
    │   ├── check-health.ps1        # Health check (all 33 containers)
    │   ├── check-health.sh         # Health check (bash)
    │   ├── reset-lab.ps1           # Full reset (Windows)
    │   └── reset-lab.sh            # Full reset (Linux/macOS)
    ├── apps/
    │   ├── corp-web/               # Corporate portal (Flask)
    │   └── internal-erp/           # ERP intranet (Flask)
    └── config/
        ├── attacker/               # Kali-style pentest box (Debian)
        ├── edge-router/            # BGP Edge Router (Alpine)
        ├── isp2-router/            # ISP2 secondary (Alpine)
        ├── ddos-proxy/             # DDoS scrubbing (Nginx)
        ├── hq-firewall/            # NGFW (Alpine + iptables)
        ├── nginx-waf/              # WAF proxy config
        ├── bastion/                # SSH jump host (Alpine)
        ├── ztna-gateway/           # WireGuard ZTNA (Alpine)
        ├── samba-ad/               # Active Directory (Samba4)
        ├── syslog-server/          # SIEM collector (rsyslog)
        ├── nac-server/             # NAC simulation (Flask)
        ├── nms/                    # Prometheus config
        ├── dc-fabric/              # Spine + Leaf switches
        ├── database/               # PostgreSQL init.sql
        ├── branch-office/          # SD-WAN + Branch PC
        ├── voip/                   # Asterisk PBX
        ├── iot/                    # MQTT IoT device
        ├── ipcam/                  # MediaMTX RTSP cameras
        ├── workstations/           # HR + DevOps workstations
        └── cloud-tier/             # Cloud app, gateway, DB, SaaS SSO
```

---

## 🛠️ Troubleshooting

### Build Fails — Network/Download Issues
```bash
# Build without cache
docker compose --profile core build --no-cache
```

### Container Immediately Exits
```bash
docker compose logs nexus-<container-name>
```

### Port Already in Use
```bash
# Check what is using port 80
netstat -ano | findstr :80      # Windows
lsof -i :80                     # Linux/macOS
```

### Low RAM — Start Core Only
```powershell
.\scripts\start-lab.ps1 -Mode core
```

### WireGuard Fails on Windows
Ensure WSL2 is enabled:
```powershell
wsl --install
wsl --set-default-version 2
```

### Full Reset
```powershell
.\scripts\reset-lab.ps1
# Then rebuild:
.\scripts\start-lab.ps1
```

---

## 📖 Additional Documentation

- `docs/student-lab-guide.md` — Step-by-step exercises for students
- `docs/instructor-walkthrough.md` — Full attack path solutions
- `docs/network-topology-map.md` — Detailed network diagram

---

> 🔒 **For educational purposes only.** All vulnerabilities are intentional and contained within the lab environment. Do not expose lab ports to the public internet.
