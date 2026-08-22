# 📸 UI & Browser Endpoints — Visual Reference & Verification Summary

> **Purpose for AI Agents:** This document provides a token-efficient, text-based structural breakdown of all live web application endpoints tested and verified in the Nexus Global Enterprise lab. Use this summary to understand UI layouts, visible fields, auth status, endpoint paths, and vulnerability injection points without loading high-resolution images.

---

## 📋 Baseline Verification Matrix (from README Table)

The testing of all browser endpoints is based on the master service matrix in the lab's `README.md`:

| Application | How to Access & Credentials | Mode 1 `core` | Mode 2 `enterprise` | Mode 3 `all` | Verified Live UI |
|:---|:---|:---:|:---:|:---:|:---:|
| **Corporate Web Portal** | `http://localhost:80` — `admin` / `NexusTechAdmin2026!` | ✅ | ✅ | ✅ | Image 1 |
| **MailHog Webmail** | `http://localhost:8025` — No auth required | ✅ | ✅ | ✅ | Image 2 |
| **MinIO Primary SAN** | `http://localhost:9001` — `nexus_san_root` / `SuperS3cUr3_B4ckup_Vault_Pass_2026!` | ✅ | ✅ | ✅ | Image 3 |
| **Grafana NMS Dashboard** | `http://localhost:3000` — `nexus_nms_admin` / `NMS@Nexus2026!` | ❌ | ✅ | ✅ | Image 4 |
| **DDoS Scrubbing Center** | `http://localhost:8080` — Public proxy endpoint | ❌ | ✅ | ✅ | Image 5 |
| **CCTV Camera Web Player** | `http://localhost:8888/nexus-lobby/` — No auth required | ❌ | ✅ | ✅ | Image 6 |
| **MinIO DR Backup SAN** | `http://localhost:9003` — `nexus_dr_admin` / `DRBackup_Nexus@2026!` | ❌ | ✅ | ✅ | Image 7 |
| **Cloud Microservice API** | `http://localhost:8090` — Endpoints: `/api/v1/config`, `/api/v1/health` | ❌ | ❌ | ✅ | Image 8 |
| **SaaS SSO Identity Portal** | `http://localhost:8443` — Use employee domain credentials | ❌ | ❌ | ✅ | Image 9 |

---

## 🔍 Detailed Live UI Breakdown (Images 1–9 + README Preview)

### 🖼️ Image 1: Corporate Web Portal (`http://localhost:80`)
* **Header / Branding:** `⚡ NEXUS GLOBAL ENTERPRISE`
* **Status Badge:** `🟢 DMZ-01 Operational`
* **Current Session:** `Logged in as: admin` | `[Sign Out]` button
* **Navigation Links:** `Overview` | `Global Tracking` | `Edge Connectivity` | `Corporate Webmail`
* **Main Feature Section:**
  * Title: *Critical Supply Chain & Hybrid Cloud Backbone*
  * **Interactive Form:** `Consignment & Hardware Dispatch Tracker`
    * Input: `Enter Tracking ID (e.g. NX-98231)`
    * Button: `[Track Asset]`
    * ⚠️ **Vulnerability (Flag 1):** SQL injection on `/?track_id=` parameter.
* **Architecture Cards:**
  1. `🔒 Perimeter Security`: Next-Gen Edge Firewalls, stateful packet filtering.
  2. `🏢 Active Directory Core`: Centralized IAM via `dc01.nexus.internal` (`10.0.2.10`).
  3. `🗄️ Isolated Data Center`: PostgreSQL (`10.0.3.20`), ERP Intranet (`10.0.3.10`), SAN storage (`10.0.3.30`).

---

### 🖼️ Image 2: MailHog Webmail Testing Server (`http://localhost:8025`)
* **Header / Branding:** `MailHog` with GitHub link & Search bar
* **Status Indicator:** `🟢 Connected` (WebSocket live updates)
* **Sidebar Controls:** `Inbox (0)`, `Clear all messages`, `Jim (Chaos monkey)`
* **Role:** Intercepts outgoing SMTP emails (password resets, notifications).

---

### 🖼️ Image 3: MinIO Primary SAN Storage Console (`http://localhost:9001`)
* **Header:** `MINIO OBJECT STORE (RELEASE LICENSE)`
* **Navigation Tree:**
  * User: `Object Browser`, `Access Keys`, `Documentation`
  * Admin: `Buckets`, `Policies`, `Identity`, `Monitoring`, `Events`, `Tiering`, `Site Replication`, `Configuration`
  * Subnet: `License`, `Health`, `Performance`
* **Content View:** `Object Browser` → `Buckets`
* **Role:** Primary SAN container (`nexus-dc-backup-storage`) on Data Center subnet `10.0.3.30`.

---

### 🖼️ Image 4: Grafana NMS Telemetry Dashboard (`http://localhost:3000`)
* **Header:** `Grafana` with search (`ctrl+k`)
* **Sidebar:** `Bookmarks`, `Starred`, `Dashboards`, `Explore`, `Alerting`, `Connections`, `Administration`
* **Welcome Screen:** `Good afternoon. Welcome to Grafana.`
* **Backend:** Connected to Prometheus (`nexus-nms-prometheus` on `10.0.2.20`).

---

### 🖼️ Image 5: DDoS Scrubbing Center Login (`http://localhost:8080`)
* **Card Header:** `⚡ NEXUS GLOBAL ENTERPRISE`
* **Card Subtitle:** `Corporate Supply Chain & Infrastructure Portal` / `Authorized Access Only — Sessions Monitored`
* **Inputs:** `DOMAIN USERNAME` (`e.g. admin`), `PASSWORD` (`Your portal password`), `[Sign In Securely]`
* **Role:** Front-facing DDoS scrubbing / rate-limiting proxy (`nexus-ddos-proxy`).

---

### 🖼️ Image 6: CCTV IP Camera Server (`http://localhost:8888`)
* **Root Response:** `404 page not found`
* **⚠️ Key Agent Insight:** MediaMTX video streaming server does not serve an index HTML page at root `/`.
* **Correct Stream URL:**
  * HLS Web Player: `http://localhost:8888/nexus-lobby/`
  * RTSP Stream: `rtsp://localhost:8554/nexus-lobby`

---

### 🖼️ Image 7: MinIO DR Backup SAN Console (`http://localhost:9003`)
* **Header:** `MINIO OBJECT STORE (RELEASE LICENSE)`
* **Navigation Tree:** Identical to primary SAN console (`Object Browser`, `Buckets`, `Policies`, `Identity`).
* **Role:** Disaster Recovery SAN container (`nexus-dc-backup-dr`) on Data Center subnet `10.0.3.35`.

---

### 🖼️ Image 8: Cloud Microservice Platform API (`http://localhost:8090`)
* **Header Bar:** `☁️ NEXUS CLOUD PLATFORM` | `AWS us-east-1` | `prod`
* **Subheader:** `Cloud Application Gateway — Kubernetes Microservice Cluster | Node: cloud-app-01.nexus-cloud.internal`
* **Documented Endpoints (6 Cards):**
  1. `GET /api/v1/health` — Cluster node status and version.
  2. `GET /api/v1/users` — Cloud IAM user directory (requires Bearer JWT token).
  3. `POST /api/v1/auth` — Authenticate and receive JWT access token (`{"user":"...", "pass":"..."}`).
  4. `GET /api/v1/fetch?url=...` — ⚠️ **SSRF Vulnerable** internal URL fetcher (Flag 4).
  5. `GET /api/v1/config` — Cloud environment config dump (instance metadata).
  6. `GET /api/v1/db-status` — Cloud DB (RDS) connectivity check.
* **Footer Metadata:** `Platform: Nexus Cloud v3.4 | Runtime: Python/Flask on K8s | JWT: HS256 | Region: us-east-1`

---

### 🖼️ Image 9: SaaS SSO Portal Protocol Notice (`http://localhost:8443`)
* **Browser State:** `ERR_SSL_PROTOCOL_ERROR` ("This site can’t provide a secure connection").
* **⚠️ Root Cause & Agent Instruction:**
  * The mock SaaS SSO portal runs standard **HTTP** on port 8443.
  * Accessing via `https://localhost:8443` causes SSL protocol failure.
  * **Always access using:** `http://localhost:8443` (HTTP without SSL).

---

### 🖼️ Image 10: Master Mode-by-Mode README Access Table Preview
* **Source:** `README.md` → Section 5 (Browser Web Applications Matrix)
* **Tested Modes:**
  - `Mode 1 (core)`: 3 apps active (`:80`, `:8025`, `:9001`)
  - `Mode 2 (enterprise)`: 7 apps active (`:80`, `:8025`, `:9001`, `:3000`, `:8080`, `:8888`, `:9003`)
  - `Mode 3 (all)`: 9 apps active (all web applications enabled)
* **Verification Status:** All 9 endpoints mapped and visually verified in live environment.

---

## 🎯 Quick Pentest & AI Agent Context Reference

| Target Parameter / Field | Corresponding UI | Vulnerability / Expected Behavior | Flag |
|:---|:---|:---|:---:|
| `track_id` | Web Portal (`:80`) Tracker | SQL Injection → dumps employee credentials | 🟢 Flag 1 |
| `/admin/server-check` | Web Portal (`:80`) Admin Area | Command Injection in ping diagnostic tool | 🟡 Flag 2 |
| `system_vault_keys` | PostgreSQL (`10.0.3.20:5432`) | DB Crown Jewels credential extraction | 🔴 Flag 3 |
| `/api/v1/fetch?url=` | Cloud Microservice (`:8090`) | SSRF → fetch internal AWS metadata & keys | 🔴 Flag 4 |
| `/dashboard` | SaaS SSO (`http://localhost:8443`) | Credential stuffing & OAuth2 auth bypass | 🟡 Flag 5 |
| `/api/bypass` | NAC Server (`10.0.2.15:8100`) | MAC Authentication Bypass (MAB) | 🟢 Flag 6 |
| Stream URL | CCTV Stream (`:8888/nexus-lobby/`) | Unauthenticated HLS video surveillance | — |
| SAN Inspection | MinIO Console (`:9001` / `:9003`) | Object storage bucket dump | — |
