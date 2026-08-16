# 🗺️ Nexus Global Enterprise - Network Topology & Subnet Map

---

## 1. Subnet Address Allocation

| Zone / Subnet Name | Subnet Range | Gateway IP | Purpose |
| :--- | :--- | :--- | :--- |
| **WAN / Internet** | `198.51.100.0/24` | `198.51.100.1` | Simulated public internet & external attacker machine |
| **DMZ (Perimeter)** | `10.0.1.0/24` | `10.0.1.1` / `10.0.1.254` | Public-facing services, WAF reverse proxy, Webmail |
| **Core Backbone** | `10.0.2.0/24` | `10.0.2.1` | Active Directory Domain Controller, SIEM, DNS |
| **Data Center (DC)** | `10.0.3.0/24` | `10.0.3.1` | Production PostgreSQL DB, Internal ERP Intranet, SAN |
| **Campus Workstations**| `10.0.4.0/24` | `10.0.4.1` | Employee clients (HR Director, DevOps Engineer) |

---

## 2. IP & Node Assignment Table

```
=================================================================================================
Container Name            Hostname            Subnet(s)                   Assigned IP(s)
=================================================================================================
nexus-edge-router         edge-gw-01          wan_net, dmz_net            198.51.100.1, 10.0.1.1
nexus-hq-firewall         fw-perimeter-01     dmz, core, dc, campus       10.0.1.254, 10.0.2.1, 
                                                                          10.0.3.1, 10.0.4.1
nexus-corp-waf-proxy      srv-waf-proxy       dmz_net                     10.0.1.10
nexus-corp-web-portal     srv-dmz-web01       dmz_net                     10.0.1.20
nexus-corp-mail-server    srv-mail-01         dmz_net                     10.0.1.30
nexus-ad-dc               dc01                core_net                    10.0.2.10
nexus-dc-prod-database    db-prod-01          dc_net                      10.0.3.20
nexus-dc-internal-erp     srv-erp-01          dc_net                      10.0.3.10
nexus-dc-backup-storage   san-backup-01       dc_net                      10.0.3.30
nexus-pc-dev-01           dev-workstation-01  campus_net                  10.0.4.20
nexus-pc-hr-01            hr-workstation-01   campus_net                  10.0.4.10
=================================================================================================
```

---

## 3. Firewall Security Policy Matrix

```
Source Zone       Destination Zone       Allowed Ports / Services            Policy Action
-------------------------------------------------------------------------------------------------
WAN (Attacker)    DMZ                   80/TCP, 443/TCP, 8025/TCP            PERMIT
WAN (Attacker)    Core / DC / Campus    ANY                                  BLOCK / DROP
DMZ               Core (AD-DC)          53, 88, 389, 636 (DNS/Kerberos/LDAP) PERMIT
DMZ               DC (Internal ERP)     8000/TCP (Intranet HTTP)             PERMIT
DMZ               DC (Database/SAN)     5432/TCP, 9000/TCP                   BLOCK / DROP
Campus (Users)    Core (AD-DC)          53, 88, 139, 389, 445 (Full AD/SMB)  PERMIT
Campus (Users)    DC (ERP & SAN)        8000/TCP, 9000/TCP, 9001/TCP         PERMIT
Campus (DevOps)   DC (Database)         22/TCP, 5432/TCP                     PERMIT
-------------------------------------------------------------------------------------------------
```
