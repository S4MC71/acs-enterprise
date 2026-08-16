# 🤖 AI Agent Handover & Project Architecture Context (v3 — Large Enterprise)

> **Last Updated:** 2026-08-16 — Full Large Enterprise rebuild complete.
> **Reference:** `enterprise-network.html` → "Large Enterprise Network" diagram

---

## 1. Project Goal & User Requirements

- **Simulate** the "Large Enterprise Network" diagram from `enterprise-network.html` using Docker.
- **Support** Black-Box, Gray-Box, and White-Box pentesting methodologies.
- **Profile System:** Two modes using Docker Compose profiles:
  - `--profile core` → Standard Lab (14 nodes, ~4GB RAM)
  - `--profile core --profile enterprise` → Full Large Enterprise (28 nodes, ~8GB)
  - `--profile core --profile enterprise --profile cloud` → All (33 nodes, ~12GB)
- **Constraint:** `enterprise-network.html` at project root must NOT be modified.

---

## 2. Network Zones — 9 Subnets

| Zone | Subnet | Real-World Equivalent |
|:---|:---|:---|
| WAN / ISP1 | `198.51.100.0/24` | Primary BGP uplink |
| WAN / ISP2 | `203.0.113.0/24` | Secondary BGP uplink (failover) |
| Cloud (AWS/Azure) | `172.16.0.0/24` | VPC / Transit Gateway peering |
| Branch Office | `10.0.5.0/24` | Dhaka Regional Branch LAN |
| VPN Tunnel | `10.0.6.0/24` | ZTNA WireGuard client addresses |
| DMZ | `10.0.1.0/24` | Public-facing services |
| Core Backbone | `10.0.2.0/24` | AD, SIEM, NAC, NMS |
| Data Center | `10.0.3.0/24` | ERP, DB, SAN, Spine/Leaf |
| Campus | `10.0.4.0/24` | Workstations, VoIP, IoT, Cameras |

---

## 3. Full Container Inventory (33 total)

### Core Profile (14 containers — Standard Lab)
| Container | IP | Role |
|:---|:---|:---|
| nexus-attacker-box | 198.51.100.100 | Kali-style Debian with full pentest toolkit |
| nexus-edge-router | 198.51.100.1 / 10.0.1.1 | BGP Edge Router A (ISP1) |
| nexus-hq-firewall | 10.0.1.254 (multi-homed) | Stateful iptables NGFW |
| nexus-corp-waf-proxy | 10.0.1.10 | Nginx WAF / Reverse Proxy |
| nexus-corp-web-portal | 10.0.1.20 | Flask app (SQLi + CMDi + 3-flag CTF) |
| nexus-corp-mail-server | 10.0.1.30 | MailHog (SMTP + Webmail) |
| nexus-corp-bastion | 10.0.1.40 / .2.5 / .4.5 | SSH Jump Host (multi-homed) |
| nexus-ad-dc | 10.0.2.10 | Samba AD (SMB shares, LDAP) |
| nexus-corp-siem-soc | 10.0.2.99 | Rsyslog SIEM with pre-seeded logs |
| nexus-dc-prod-database | 10.0.3.20 | PostgreSQL (Crown Jewels + Flag 3) |
| nexus-dc-internal-erp | 10.0.3.10 | Flask ERP Intranet |
| nexus-dc-backup-storage | 10.0.3.30 | MinIO SAN |
| nexus-pc-dev-01 | 10.0.4.20 | DevOps workstation (tahmed) |
| nexus-pc-hr-01 | 10.0.4.10 | HR workstation (sjenkins) |

### Enterprise Profile (17 additional containers)
| Container | IP | Role |
|:---|:---|:---|
| nexus-isp2-router | 203.0.113.1 | ISP2 Secondary BGP uplink |
| nexus-ddos-proxy | 203.0.113.10 | DDoS Scrubbing Center (Nginx rate-limit) |
| nexus-ztna-gateway | 10.0.1.50 / 10.0.6.1 | WireGuard ZTNA VPN Gateway |
| nexus-nac-server | 10.0.2.15 | NAC/ISE 802.1X simulation (MAC bypass vuln) |
| nexus-nms-prometheus | 10.0.2.20 | Prometheus scraper |
| nexus-nms-grafana | 10.0.2.21 | Grafana NMS dashboard |
| nexus-dc-spine-1 | 10.0.3.241 | DC Spine Switch 1 (BGP-EVPN sim) |
| nexus-dc-spine-2 | 10.0.3.242 | DC Spine Switch 2 |
| nexus-dc-leaf-1 | 10.0.3.243 | DC Leaf Switch 1 (ToR) |
| nexus-dc-leaf-2 | 10.0.3.244 | DC Leaf Switch 2 (ToR) |
| nexus-dc-backup-dr | 10.0.3.35 | DR/Backup MinIO (separate from primary) |
| nexus-branch-sdwan | 203.0.113.50 / 10.0.5.1 | Branch SD-WAN Edge (WireGuard) |
| nexus-branch-pc-01 | 10.0.5.10 | Branch employee PC (ibrahim) |
| nexus-voip-pbx | 10.0.4.50 | Asterisk PBX (SIP brute-force target) |
| nexus-iot-device-01 | 10.0.4.70 | MQTT IoT sensor (unauthenticated broker) |
| nexus-ipcam-server | 10.0.4.60 | MediaMTX RTSP camera server |

### Cloud Profile (5 additional containers)
| Container | IP | Role |
|:---|:---|:---|
| nexus-cloud-gateway | 172.16.0.1 | AWS Transit Gateway simulation |
| nexus-cloud-lb | 172.16.0.10 | HAProxy Cloud Load Balancer |
| nexus-cloud-app | 172.16.0.20 | Flask microservice (SSRF + weak JWT) |
| nexus-cloud-db | 172.16.0.30 | PostgreSQL Cloud DB (RDS simulation) |
| nexus-saas-sso | 172.16.0.40 | SaaS SSO (SAML/OAuth2 mock) |

---

## 4. Pentesting Entry Points & Attack Paths

### Entry Points by Mode

| Mode | Entry Point | Credentials |
|:---|:---|:---|
| Black-Box | `docker exec -it nexus-attacker-box bash` | None |
| Gray-Box DevOps | `docker exec -it nexus-pc-dev-01 bash` | `tahmed / DevOpsP@ss2026!` |
| Gray-Box HR | `docker exec -it nexus-pc-hr-01 bash` | `sjenkins / HrDirector9921!` |
| Gray-Box Branch | `docker exec -it nexus-branch-pc-01 bash` | `ibrahim / Branch@2026` |
| Bastion SSH | `ssh devops-remote@localhost -p 2222` | `devops-remote / devops-remote@123` |
| White-Box / Blue-Team | `docker exec -it nexus-corp-siem-soc bash` | Root |
| Web Admin | `http://localhost:80` | `admin / NexusTechAdmin2026!` |
| Grafana NMS | `http://localhost:3000` | `nexus_nms_admin / NMS@Nexus2026!` |
| Cloud App | `http://localhost:8090` | No auth required |
| SaaS SSO | `http://localhost:8443` | Domain creds or OAuth2 |
| VoIP SIP | `sip:1003@localhost:5060` | `1234` |

### Attack Path A — Classic Black-Box (Core)
1. Recon: `nmap 198.51.100.0/24` → WAF at `10.0.1.10:80`
2. Web Recon: `robots.txt`, `/changelog.txt`, `/admin-console/`
3. SQLi: `/?track_id=NX-1' UNION SELECT ...` → **Flag 1**
4. Login Brute-Force → `admin / NexusTechAdmin2026!`
5. Command Injection: `/admin/server-check?host=127.0.0.1; cat /flag.txt` → **Flag 2**
6. SMB Enum: `smbclient -L //10.0.2.10 -N` → read `sync_prod_db.sh` (DB creds)
7. DB Access: `psql -h 10.0.3.20 -U nexus_admin` → `SELECT * FROM system_vault_keys` → **Flag 3**

### Attack Path B — Branch/SD-WAN Pivot (Enterprise)
1. SSH brute-force Branch PC: `hydra -l ibrahim -P rockyou.txt 10.0.5.10 ssh`
2. Read `/etc/wireguard/wg0.conf` (world-readable PSK leak) → **Flag: ZTNA bypass possible**
3. Pivot via SD-WAN tunnel to HQ Core (10.0.2.x)
4. AD enumeration → SMB → DB crown jewels

### Attack Path C — Cloud SSRF (Cloud Profile)
1. Discover cloud app: `http://localhost:8090/api/v1/config` → internal IPs
2. SSRF: `GET /api/v1/fetch?url=http://172.16.0.20/api/v1/secrets`
3. Extract cloud credentials (S3 key, RDS password) → **Flag: Cloud Tier flag**
4. JWT crack: `hashcat -a 0 <jwt> rockyou.txt` → algorithm `HS256`, weak secret

### Attack Path D — VoIP SIP Attack (Enterprise)
1. Enumerate SIP accounts: `svmap 10.0.4.50`
2. Brute-force: `svcrack -u 1003 -d rockyou.txt 10.0.4.50` → `1003:1234`
3. Register SIP endpoint, listen to conference room 9000

### Attack Path E — IoT/MQTT (Enterprise)
1. Scan: `nmap -p 1883 10.0.4.70`
2. Subscribe all topics: `mosquitto_sub -h 10.0.4.70 -t '#' -v`
3. Read `nexus/internal/infra/alerts` → leaks DC IPs, port numbers

### Attack Path F — NAC MAC Bypass (Enterprise)
1. Discover NAC: `http://10.0.2.15:8100`
2. Exploit MAB bypass: `POST /api/bypass?mac=AA:BB:CC:DD:EE:FF`
3. Receive **NAC Bypass Flag**

---

## 5. CTF Flags Reference

| Flag | Value | Where Found |
|:---|:---|:---|
| Flag 1 | `FLAG{SQLi_NEXUS_PORTAL_NX98231_OWNED}` | SQLi on `/?track_id=` |
| Flag 2 | `FLAG{CMD_INJ3CT10N_PORTAL_COMPR0M1S3D}` | CMDi in `/admin/server-check` |
| Flag 3 | `FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}` | PostgreSQL `system_vault_keys` |
| Flag 4 | `FLAG{CL0UD_T13R_C0MPR0M1S3D_AWS_NEXUS_2026!}` | Cloud app `/api/v1/secrets` |
| Flag 5 | `FLAG{SAAS_SS0_C0RPO_ID3NT1TY_BYPASSD_2026}` | SaaS SSO `/dashboard` |
| Flag 6 | `FLAG{NAC_M4C_BYPA55_802_1X_C1RC_UMVENT3D_2026}` | NAC `/api/bypass` |

---

## 6. Key Technical Notes for Future AI Models

1. **Docker Compose Profiles:** Containers need `profiles: [core, enterprise]` to appear in BOTH modes. Cloud-only containers have `profiles: [cloud]`.
2. **YAML Dollar Signs:** PostgreSQL password `Nexu$$Prod2026!Sec` uses `$$` to escape `$` in docker-compose YAML.
3. **Bastion multi-homed:** `corp-bastion` appears on 3 networks intentionally (DMZ + Core + Campus). This enables it to act as a pivot point.
4. **WireGuard on Windows Docker Desktop:** Requires WSL2 backend. `cap_add: [NET_ADMIN, SYS_MODULE]` and `sysctls: net.ipv4.ip_forward=1` are required.
5. **MediaMTX RTSP:** The camera binary is downloaded at build time from GitHub releases. If offline, provide a pre-downloaded binary in `config/ipcam/`.
6. **IoT MQTT:** Broker is intentionally unauthenticated (`allow_anonymous true`). This is the vulnerability.
7. **Cloud App SSRF:** `/api/v1/fetch?url=` fetches any URL. Key demo: fetch `http://172.16.0.20/api/v1/secrets` from inside the cloud subnet.
8. **DO NOT modify `enterprise-network.html`** — it is the source diagram reference only.

---

## 7. Directory Structure (Complete)

```
acs-enterprise/
├── enterprise-network.html          # UNTOUCHED — Architecture reference diagram
├── AI_AGENT_CONTEXT.md              # This document
└── lab/
    ├── docker-compose.yml           # Master compose (3 profiles, 33 containers)
    ├── scripts/
    │   ├── start-lab.ps1            # Interactive profile launcher
    │   ├── check-health.ps1         # 33-container health check
    │   ├── reset-lab.ps1 / .sh
    │   └── start-lab.sh
    ├── apps/
    │   ├── corp-web/                # Flask portal (SQLi, CMDi, CTF)
    │   └── internal-erp/            # Flask ERP intranet
    ├── config/
    │   ├── attacker/                # Debian pentest box
    │   ├── edge-router/             # ISP1 BGP Router
    │   ├── isp2-router/             # ISP2 BGP Router (enterprise)
    │   ├── ddos-proxy/              # Nginx DDoS scrubbing (enterprise)
    │   ├── hq-firewall/             # iptables NGFW
    │   ├── nginx-waf/               # WAF reverse proxy
    │   ├── bastion/                 # SSH jump host
    │   ├── ztna-gateway/            # WireGuard ZTNA (enterprise)
    │   ├── samba-ad/                # AD DC (Samba4)
    │   ├── syslog-server/           # SIEM rsyslog
    │   ├── nac-server/              # NAC Flask (enterprise)
    │   ├── nms/                     # Prometheus config (enterprise)
    │   ├── dc-fabric/               # Spine/Leaf switches (enterprise)
    │   ├── database/                # PostgreSQL init.sql
    │   ├── branch-office/           # Branch SD-WAN + PC (enterprise)
    │   ├── voip/                    # Asterisk PBX (enterprise)
    │   ├── iot/                     # MQTT IoT device (enterprise)
    │   ├── ipcam/                   # MediaMTX RTSP cameras (enterprise)
    │   ├── workstations/            # HR + DevOps workstations
    │   └── cloud-tier/              # Cloud gateway, app, DB, SaaS (cloud)
    └── docs/
        ├── student-lab-guide.md
        ├── instructor-walkthrough.md
        └── network-topology-map.md
```
