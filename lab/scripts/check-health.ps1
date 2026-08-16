# Nexus Enterprise Lab — Full Health Check
# Covers all 33 containers across 3 profiles

param([string]$Profile = "all")

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " 🔍 Nexus Enterprise Lab — Health Check" -ForegroundColor Yellow
Write-Host "============================================================" -ForegroundColor Cyan

$allContainers = @(
    # core profile
    @{Name="nexus-edge-router";      Zone="[WAN]   "; Role="Edge Router (BGP-A / ISP1)";   Profile="core"},
    @{Name="nexus-hq-firewall";      Zone="[NGFW]  "; Role="Perimeter Firewall";           Profile="core"},
    @{Name="nexus-corp-waf-proxy";   Zone="[DMZ]   "; Role="Nginx WAF / Reverse Proxy";    Profile="core"},
    @{Name="nexus-corp-web-portal";  Zone="[DMZ]   "; Role="Corporate Web Portal";         Profile="core"},
    @{Name="nexus-corp-mail-server"; Zone="[DMZ]   "; Role="Mail Server (MailHog)";        Profile="core"},
    @{Name="nexus-corp-bastion";     Zone="[DMZ]   "; Role="SSH Bastion Jump Host";        Profile="core"},
    @{Name="nexus-ad-dc";            Zone="[Core]  "; Role="Active Directory DC (Samba)";  Profile="core"},
    @{Name="nexus-corp-siem-soc";    Zone="[Core]  "; Role="SIEM Syslog Collector";        Profile="core"},
    @{Name="nexus-dc-prod-database"; Zone="[DC]    "; Role="PostgreSQL DB (Crown Jewels)"; Profile="core"},
    @{Name="nexus-dc-internal-erp";  Zone="[DC]    "; Role="Internal ERP Intranet";        Profile="core"},
    @{Name="nexus-dc-backup-storage";Zone="[DC]    "; Role="MinIO SAN Storage";            Profile="core"},
    @{Name="nexus-pc-dev-01";        Zone="[Campus]"; Role="DevOps Workstation (tahmed)";  Profile="core"},
    @{Name="nexus-pc-hr-01";         Zone="[Campus]"; Role="HR Workstation (sjenkins)";    Profile="core"},
    # enterprise profile
    @{Name="nexus-isp2-router";      Zone="[WAN]   "; Role="ISP2 Router (BGP-B Secondary)"; Profile="enterprise"},
    @{Name="nexus-ddos-proxy";       Zone="[WAN]   "; Role="DDoS Protection Proxy";         Profile="enterprise"},
    @{Name="nexus-ztna-gateway";     Zone="[DMZ]   "; Role="ZTNA / Zero Trust VPN GW";      Profile="enterprise"},
    @{Name="nexus-nac-server";       Zone="[Core]  "; Role="NAC ISE (802.1X Simulation)";   Profile="enterprise"},
    @{Name="nexus-nms-prometheus";   Zone="[Core]  "; Role="NMS Prometheus";                Profile="enterprise"},
    @{Name="nexus-nms-grafana";      Zone="[Core]  "; Role="NMS Grafana Dashboard";         Profile="enterprise"},
    @{Name="nexus-dc-spine-1";       Zone="[DC]    "; Role="DC Spine Switch 1 (BGP)";       Profile="enterprise"},
    @{Name="nexus-dc-spine-2";       Zone="[DC]    "; Role="DC Spine Switch 2 (BGP)";       Profile="enterprise"},
    @{Name="nexus-dc-leaf-1";        Zone="[DC]    "; Role="DC Leaf Switch 1 (ToR)";        Profile="enterprise"},
    @{Name="nexus-dc-leaf-2";        Zone="[DC]    "; Role="DC Leaf Switch 2 (ToR)";        Profile="enterprise"},
    @{Name="nexus-dc-backup-dr";     Zone="[DC]    "; Role="DR/Backup Storage (MinIO)";     Profile="enterprise"},
    @{Name="nexus-branch-sdwan";     Zone="[Branch]"; Role="Branch SD-WAN Edge (Dhaka)";    Profile="enterprise"},
    @{Name="nexus-branch-pc-01";     Zone="[Branch]"; Role="Branch Employee PC (ibrahim)";  Profile="enterprise"},
    @{Name="nexus-voip-pbx";         Zone="[Campus]"; Role="VoIP PBX Asterisk (SIP)";       Profile="enterprise"},
    @{Name="nexus-iot-device-01";    Zone="[Campus]"; Role="IoT MQTT Sensor (unauthenticated)"; Profile="enterprise"},
    @{Name="nexus-ipcam-server";     Zone="[Campus]"; Role="IP Camera RTSP Server";         Profile="enterprise"},
    # cloud profile
    @{Name="nexus-cloud-gateway";    Zone="[Cloud] "; Role="Transit Gateway (AWS TGW sim)"; Profile="cloud"},
    @{Name="nexus-cloud-lb";         Zone="[Cloud] "; Role="Cloud Load Balancer (ALB)";     Profile="cloud"},
    @{Name="nexus-cloud-app";        Zone="[Cloud] "; Role="K8s Microservice (SSRF vuln)";  Profile="cloud"},
    @{Name="nexus-cloud-db";         Zone="[Cloud] "; Role="Cloud Managed DB (RDS sim)";    Profile="cloud"},
    @{Name="nexus-saas-sso";         Zone="[Cloud] "; Role="SaaS SSO Portal (SAML/OAuth2)"; Profile="cloud"},
)

$running = 0
$stopped = 0
$notFound = 0

$coreCount = 0; $coreRun = 0
$entCount  = 0; $entRun  = 0
$cloudCount= 0; $cloudRun= 0

foreach ($c in $allContainers) {
    $status = docker inspect -f '{{.State.Status}}' $c.Name 2>$null
    switch ($c.Profile) {
        "core"       { $coreCount++ }
        "enterprise" { $entCount++  }
        "cloud"      { $cloudCount++ }
    }
    if ($status -eq "running") {
        Write-Host (" ✓ {0,-35} {1,-10} {2}" -f $c.Name, $c.Zone, $c.Role) -ForegroundColor Green
        $running++
        switch ($c.Profile) {
            "core"       { $coreRun++ }
            "enterprise" { $entRun++  }
            "cloud"      { $cloudRun++ }
        }
    } elseif ($null -eq $status -or $status -eq "") {
        Write-Host (" ○ {0,-35} {1,-10} {2}  [not deployed]" -f $c.Name, $c.Zone, $c.Role) -ForegroundColor DarkGray
        $notFound++
    } else {
        Write-Host (" ✗ {0,-35} {1,-10} {2}  [{3}]" -f $c.Name, $c.Zone, $c.Role, $status) -ForegroundColor Red
        $stopped++
    }
}

$total = $allContainers.Count
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════" -ForegroundColor DarkGray
Write-Host ("  Running: {0}/{1}  |  Core: {2}/{3}  |  Enterprise: {4}/{5}  |  Cloud: {6}/{7}" -f `
    $running, $total, $coreRun, $coreCount, $entRun, $entCount, $cloudRun, $cloudCount) -ForegroundColor Cyan

if ($stopped -gt 0) {
    Write-Host "  ⚠️  $stopped container(s) in error state" -ForegroundColor Red
}
if ($notFound -gt 0) {
    Write-Host "  ○  $notFound container(s) not deployed (use appropriate --profile to start)" -ForegroundColor DarkGray
}

Write-Host ""
if ($coreRun -eq $coreCount) {
    Write-Host "  [Core]       ✅ All core containers healthy" -ForegroundColor Green
}
if ($entRun -gt 0) {
    Write-Host ("  [Enterprise] {0}/{1} enterprise containers running" -f $entRun, $entCount) -ForegroundColor Magenta
}
if ($cloudRun -gt 0) {
    Write-Host ("  [Cloud]      {0}/{1} cloud containers running" -f $cloudRun, $cloudCount) -ForegroundColor Blue
}

Write-Host ""
Write-Host "  Quick Start Commands:" -ForegroundColor Yellow
Write-Host "    Standard:   .\scripts\start-lab.ps1 -Mode core"
Write-Host "    Enterprise: .\scripts\start-lab.ps1 -Mode enterprise"
Write-Host "    Full:       .\scripts\start-lab.ps1 -Mode all"
