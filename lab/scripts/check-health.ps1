# ============================================================
#  Nexus Enterprise Lab - Health Diagnostic Script
#  Supports: -Mode core / -Mode enterprise / -Mode all / -Mode auto
# ============================================================

param(
    [Parameter(Position=0)]
    [ValidateSet("auto", "core", "enterprise", "all", "cloud")]
    [string]$Mode = "auto"
)

# 0. Check if Docker is available
$dockerInstalled = Get-Command docker -ErrorAction SilentlyContinue
if (-not $dockerInstalled) {
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " [!] Docker is not detected in PATH!" -ForegroundColor Yellow
    Write-Host " Please install and start Docker Desktop before running health check." -ForegroundColor DarkGray
    Write-Host "============================================================" -ForegroundColor Red
    exit 1
}

# Check if Docker daemon is responsive
$dockerRunning = docker info 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "============================================================" -ForegroundColor Red
    Write-Host " [!] Docker Desktop is not running!" -ForegroundColor Yellow
    Write-Host " Please start Docker Desktop and wait until the engine is active." -ForegroundColor DarkGray
    Write-Host "============================================================" -ForegroundColor Red
    exit 1
}

$containersMaster = @(
    # Core Profile (13 containers)
    @{Name="nexus-edge-router";      Zone="[WAN]   "; Role="Edge Router (BGP-A / ISP1)";   Profile="core"},
    @{Name="nexus-hq-firewall";      Zone="[NGFW]  "; Role="Perimeter Firewall";           Profile="core"},
    @{Name="nexus-corp-waf-proxy";   Zone="[DMZ]   "; Role="Nginx WAF / Reverse Proxy";    Profile="core"},
    @{Name="nexus-corp-web-portal";  Zone="[DMZ]   "; Role="Corporate Web Portal (Flask)"; Profile="core"},
    @{Name="nexus-corp-mail-server"; Zone="[DMZ]   "; Role="Mail Server (MailHog)";        Profile="core"},
    @{Name="nexus-corp-bastion";     Zone="[DMZ]   "; Role="SSH Bastion Jump Host";        Profile="core"},
    @{Name="nexus-ad-dc";            Zone="[Core]  "; Role="Active Directory DC (Samba)";  Profile="core"},
    @{Name="nexus-corp-siem-soc";    Zone="[Core]  "; Role="SIEM Syslog Collector";        Profile="core"},
    @{Name="nexus-dc-prod-database"; Zone="[DC]    "; Role="PostgreSQL DB (Crown Jewels)"; Profile="core"},
    @{Name="nexus-dc-internal-erp";  Zone="[DC]    "; Role="Internal ERP Intranet";        Profile="core"},
    @{Name="nexus-dc-backup-storage";Zone="[DC]    "; Role="MinIO SAN Storage";            Profile="core"},
    @{Name="nexus-pc-dev-01";        Zone="[Campus]"; Role="DevOps Workstation (tahmed)";  Profile="core"},
    @{Name="nexus-pc-hr-01";         Zone="[Campus]"; Role="HR Workstation (sjenkins)";    Profile="core"},

    # Enterprise Profile (+16 containers)
    @{Name="nexus-isp2-router";      Zone="[WAN]   "; Role="ISP2 Router (BGP-B Secondary)"; Profile="enterprise"},
    @{Name="nexus-ddos-proxy";       Zone="[WAN]   "; Role="DDoS Protection Proxy";         Profile="enterprise"},
    @{Name="nexus-ztna-gateway";     Zone="[DMZ]   "; Role="ZTNA / Zero Trust VPN GW";      Profile="enterprise"},
    @{Name="nexus-nac-server";       Zone="[Core]  "; Role="NAC ISE (802.1X Simulation)";   Profile="enterprise"},
    @{Name="nexus-nms-prometheus";   Zone="[Core]  "; Role="NMS Prometheus Scraper";        Profile="enterprise"},
    @{Name="nexus-nms-grafana";      Zone="[Core]  "; Role="NMS Grafana Dashboard";         Profile="enterprise"},
    @{Name="nexus-dc-spine-1";       Zone="[DC]    "; Role="DC Spine Switch 1 (BGP)";       Profile="enterprise"},
    @{Name="nexus-dc-spine-2";       Zone="[DC]    "; Role="DC Spine Switch 2 (BGP)";       Profile="enterprise"},
    @{Name="nexus-dc-leaf-1";        Zone="[DC]    "; Role="DC Leaf Switch 1 (ToR)";        Profile="enterprise"},
    @{Name="nexus-dc-leaf-2";        Zone="[DC]    "; Role="DC Leaf Switch 2 (ToR)";        Profile="enterprise"},
    @{Name="nexus-dc-backup-dr";     Zone="[DC]    "; Role="DR Backup Storage (MinIO)";     Profile="enterprise"},
    @{Name="nexus-branch-sdwan";     Zone="[Branch]"; Role="Branch SD-WAN Edge (Dhaka)";    Profile="enterprise"},
    @{Name="nexus-branch-pc-01";     Zone="[Branch]"; Role="Branch Employee PC (ibrahim)";  Profile="enterprise"},
    @{Name="nexus-voip-pbx";         Zone="[Campus]"; Role="VoIP PBX Asterisk (SIP)";       Profile="enterprise"},
    @{Name="nexus-iot-device-01";    Zone="[Campus]"; Role="IoT MQTT Sensor (Broker)";       Profile="enterprise"},
    @{Name="nexus-ipcam-server";     Zone="[Campus]"; Role="IP Camera RTSP Server";         Profile="enterprise"},

    # Cloud Profile (+5 containers)
    @{Name="nexus-cloud-gateway";    Zone="[Cloud] "; Role="Transit Gateway (AWS TGW sim)"; Profile="cloud"},
    @{Name="nexus-cloud-lb";         Zone="[Cloud] "; Role="Cloud Load Balancer (ALB)";     Profile="cloud"},
    @{Name="nexus-cloud-app";        Zone="[Cloud] "; Role="Cloud Microservice (SSRF vuln)";Profile="cloud"},
    @{Name="nexus-cloud-db";         Zone="[Cloud] "; Role="Cloud Managed DB (RDS sim)";    Profile="cloud"},
    @{Name="nexus-saas-sso";         Zone="[Cloud] "; Role="SaaS SSO Portal (SAML/OAuth2)"; Profile="cloud"}
)

# Step 1: Detect running containers
$runningMap = @{}
foreach ($c in $containersMaster) {
    $status = docker inspect -f "{{.State.Status}}" $c.Name 2>$null
    if ($status -eq "running") {
        $runningMap[$c.Name] = $true
    }
}

$coreRunning = 0
$entRunning = 0
$cloudRunning = 0
foreach ($c in $containersMaster) {
    if ($runningMap.ContainsKey($c.Name)) {
        if ($c.Profile -eq "core") { $coreRunning++ }
        if ($c.Profile -eq "enterprise") { $entRunning++ }
        if ($c.Profile -eq "cloud") { $cloudRunning++ }
    }
}

# Auto-detect mode if not explicitly specified
$detectedMode = "core"
if ($cloudRunning -gt 0) {
    $detectedMode = "all"
} elseif ($entRunning -gt 0) {
    $detectedMode = "enterprise"
} elseif ($coreRunning -gt 0) {
    $detectedMode = "core"
} else {
    $detectedMode = "none"
}

$targetMode = $Mode.ToLower()
if ($targetMode -eq "auto") {
    $targetMode = if ($detectedMode -eq "none") { "all" } else { $detectedMode }
}

# Filter container list based on selected mode
$activeList = @()
$modeTitle = ""
switch ($targetMode) {
    "core" {
        $activeList = $containersMaster | Where-Object { $_.Profile -eq "core" }
        $modeTitle = "Mode 1: Standard Infrastructure (13 Nodes)"
    }
    "enterprise" {
        $activeList = $containersMaster | Where-Object { $_.Profile -in @("core", "enterprise") }
        $modeTitle = "Mode 2: Advanced Enterprise (29 Nodes)"
    }
    "cloud" {
        $activeList = $containersMaster | Where-Object { $_.Profile -eq "cloud" }
        $modeTitle = "Cloud Tier Only (5 Nodes)"
    }
    default {
        $activeList = $containersMaster
        $modeTitle = "Mode 3: Full Hybrid Cloud (34 Nodes)"
    }
}

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " [?] Nexus Enterprise Lab - Health Diagnostic" -ForegroundColor Yellow
Write-Host " Scope: $modeTitle" -ForegroundColor Cyan
if ($detectedMode -ne "none") {
    Write-Host " Active Deployment Detected: $detectedMode" -ForegroundColor Green
} else {
    Write-Host " Active Deployment: No running lab containers detected" -ForegroundColor Yellow
}
Write-Host "============================================================" -ForegroundColor Cyan

$runningCount = 0
$errorCount   = 0
$stoppedCount = 0

foreach ($c in $activeList) {
    $status = docker inspect -f "{{.State.Status}}" $c.Name 2>$null
    if ($status -eq "running") {
        Write-Host ("  [v] {0,-32} {1,-10} {2}" -f $c.Name, $c.Zone, $c.Role) -ForegroundColor Green
        $runningCount++
    } elseif ($null -eq $status -or $status -eq "") {
        Write-Host ("  [o] {0,-32} {1,-10} {2}  [not deployed]" -f $c.Name, $c.Zone, $c.Role) -ForegroundColor DarkGray
        $stoppedCount++
    } else {
        Write-Host ("  [x] {0,-32} {1,-10} {2}  [Status: {3}]" -f $c.Name, $c.Zone, $c.Role, $status) -ForegroundColor Red
        $errorCount++
    }
}

$totalTarget = $activeList.Count
Write-Host ""
Write-Host "============================================================" -ForegroundColor DarkGray
Write-Host ("  Target Scope: {0,-2} | Running: {1,-2}/{2,-2} | Not Deployed: {3,-2} | Errors: {4,-2}" -f `
    $targetMode.ToUpper(), $runningCount, $totalTarget, $stoppedCount, $errorCount) -ForegroundColor Cyan

if ($runningCount -eq $totalTarget -and $totalTarget -gt 0) {
    Write-Host "  [+] All containers in this scope are HEALTHY and ONLINE!" -ForegroundColor Green
} elseif ($errorCount -gt 0) {
    Write-Host "  [!] $errorCount container(s) encountered an error! Check: docker compose logs" -ForegroundColor Red
} elseif ($runningCount -eq 0) {
    Write-Host "  [*] Lab is not running. Start it with: .\scripts\start-lab.ps1 -Mode $targetMode" -ForegroundColor Yellow
} else {
    Write-Host "  [*] Partial deployment: $runningCount of $totalTarget running." -ForegroundColor Cyan
}

Write-Host ""
Write-Host "  Filter usage:" -ForegroundColor DarkGray
Write-Host "    .\scripts\check-health.ps1                  # Auto-detects running mode" -ForegroundColor DarkGray
Write-Host "    .\scripts\check-health.ps1 -Mode core       # Checks only Core (13 nodes)" -ForegroundColor DarkGray
Write-Host "    .\scripts\check-health.ps1 -Mode enterprise # Checks Enterprise (29 nodes)" -ForegroundColor DarkGray
Write-Host "    .\scripts\check-health.ps1 -Mode all        # Checks All (34 nodes)" -ForegroundColor DarkGray
Write-Host ""
