# 🎯 Nexus Global Enterprise - Penetration Testing Student Lab Guide

Welcome to the **Nexus Global Enterprise Security Assessment**. In this lab, you will act as a Red Team penetration tester evaluating the defensive posture of a simulated multi-tier corporate network.

---

## 1. Engagement Rules of Engagement (RoE)

- **Target Organization:** Nexus Global Logistics & Enterprise Systems (`nexus.internal`)
- **Primary Objective:** Assess perimeter exposure, gain initial access, pivot through internal security boundaries, and retrieve the **Data Center Crown Jewels (Flags)**.
- **Flag Format:** `FLAG{...}`

---

## 2. Lab Scenarios

### 🅰️ Scenario 1: External Black-Box Penetration Test
You have **Zero Prior Knowledge**. You are given only the external perimeter IP address.

1. **Access Point:** Connect to the pre-configured attacker container:
   ```bash
   docker exec -it nexus-attacker-box bash
   ```
2. **Scope / Target:** `198.51.100.10` (or `10.0.1.10` via Edge Gateway).
3. **Milestones:**
   - [ ] **Phase 1 - Reconnaissance:** Discover exposed ports and running services on the perimeter.
   - [ ] **Phase 2 - Initial Foothold:** Exploit web application vulnerability on the DMZ Web Portal to gain command execution.
   - [ ] **Phase 3 - Network Pivoting:** Establish a tunnel / SOCKS proxy (e.g. using `chisel`, `socat`, or reverse shells) to route traffic through the DMZ host into the Core Backbone (`10.0.2.0/24`) and Data Center (`10.0.3.0/24`).
   - [ ] **Phase 4 - Active Directory Enumeration:** Query `nexus.internal` (`10.0.2.10`) for domain accounts and readable SMB shares.
   - [ ] **Phase 5 - Crown Jewels:** Access Data Center Database (`10.0.3.20`) or Intranet ERP (`10.0.3.10:8000`) and extract production database secrets.

---

### 🅱️ Scenario 2: Gray-Box / Assumed Breach (Campus Insider)
You start with low-privilege access on an internal campus workstation.

1. **Access Point:**
   - DevOps Workstation:
     ```bash
     docker exec -it nexus-pc-dev-01 bash
     # User: tahmed | Pass: DevOpsP@ss2026!
     ```
   - HR Workstation:
     ```bash
     docker exec -it nexus-pc-hr-01 bash
     # User: sjenkins | Pass: HrDirector9921!
     ```
2. **Milestones:**
   - [ ] Inspect local environment, user privileges, and bash history.
   - [ ] Discover internal shares on the Active Directory Domain Controller (`10.0.2.10`).
   - [ ] Find hardcoded infrastructure database credentials in internal scripts.
   - [ ] Authenticate directly to the production PostgreSQL cluster (`10.0.3.20`).

---

## 3. Useful Tools Available in Attacker Box

| Tool | Purpose / Example Usage |
| :--- | :--- |
| **Nmap** | `nmap -sS -sV -p- 198.51.100.10` |
| **Curl** | `curl -i http://198.51.100.10/` |
| **Smbclient** | `smbclient -L //10.0.2.10 -N` |
| **PostgreSQL Client** | `psql -h 10.0.3.20 -U nexus_admin -d nexus_prod` |
| **Impacket Tools** | `GetNPUsers.py nexus.internal/ -no-pass -dc-ip 10.0.2.10` |

---

## 4. Assessment Deliverables

Submit a brief Penetration Testing Report containing:
1. Executive Summary & Risk Level.
2. Step-by-step Attack Chain (Screenshots & Command Logs).
3. Retrieved Flags and Exposed Credentials.
4. Remediation Recommendations for Network Defense.
