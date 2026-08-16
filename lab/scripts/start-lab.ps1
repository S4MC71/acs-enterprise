# ============================================================
#  Nexus Global Enterprise — Lab Startup Script (PowerShell)
#  Supports Docker Compose Profile selection
# ============================================================

param(
    [Parameter()]
    [ValidateSet("core", "enterprise", "all")]
    [string]$Mode = ""
)

function Show-Banner {
    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    NEXUS GLOBAL ENTERPRISE — PENTESTING LAB LAUNCHER         ║" -ForegroundColor Cyan
    Write-Host "║    Large Enterprise Network Simulation                        ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Show-Menu {
    Write-Host "  Select Lab Mode:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  [1] STANDARD LAB (Core Only)      ~14 containers | ~4 GB RAM" -ForegroundColor Green
    Write-Host "      ✓ Attacker Box, Edge Router, Firewall, WAF, Web Portal"
    Write-Host "      ✓ Mail Server, Bastion, Active Directory, SIEM"
    Write-Host "      ✓ PostgreSQL DB, ERP Intranet, MinIO SAN, Workstations"
    Write-Host ""
    Write-Host "  [2] LARGE ENTERPRISE               ~28 containers | ~8 GB RAM" -ForegroundColor Magenta
    Write-Host "      ✓ Everything in Standard PLUS:"
    Write-Host "      ✓ Dual ISP + DDoS Protection, ZTNA/VPN Gateway"
    Write-Host "      ✓ NAC Server, NMS (Grafana+Prometheus)"
    Write-Host "      ✓ DC Spine/Leaf Fabric (4 switches)"
    Write-Host "      ✓ Branch Office (SD-WAN + PC)"
    Write-Host "      ✓ VoIP PBX (Asterisk), IoT MQTT, IP Cameras (RTSP)"
    Write-Host ""
    Write-Host "  [3] FULL (Enterprise + Cloud)      ~33 containers | ~10-12 GB RAM" -ForegroundColor Red
    Write-Host "      ✓ Everything PLUS:"
    Write-Host "      ✓ Cloud Tier: Transit Gateway, Load Balancer"
    Write-Host "      ✓ Kubernetes-style Microservice (SSRF vulnerable)"
    Write-Host "      ✓ Cloud DB (RDS simulation), SaaS SSO Portal"
    Write-Host ""
    Write-Host "  [4] CLOUD TIER ONLY               ~5 containers  | ~2 GB RAM" -ForegroundColor Blue
    Write-Host ""
    Write-Host "  [Q] Quit" -ForegroundColor DarkGray
    Write-Host ""
}

Show-Banner

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$labDir    = Split-Path -Parent $scriptDir

if ($Mode -ne "") {
    switch ($Mode) {
        "core"       { $choice = "1" }
        "enterprise" { $choice = "2" }
        "all"        { $choice = "3" }
    }
} else {
    Show-Menu
    $choice = Read-Host "  Enter your choice [1/2/3/4/Q]"
}

switch ($choice.ToUpper()) {
    "1" {
        Write-Host "[*] Starting STANDARD LAB (core profile)..." -ForegroundColor Green
        $profiles = "--profile core"
        $label = "Standard Lab"
    }
    "2" {
        Write-Host "[*] Starting LARGE ENTERPRISE (core + enterprise profiles)..." -ForegroundColor Magenta
        $profiles = "--profile core --profile enterprise"
        $label = "Large Enterprise"
    }
    "3" {
        Write-Host "[*] Starting FULL LAB (all profiles)..." -ForegroundColor Red
        $profiles = "--profile core --profile enterprise --profile cloud"
        $label = "Full Enterprise + Cloud"
    }
    "4" {
        Write-Host "[*] Starting CLOUD TIER ONLY (cloud profile)..." -ForegroundColor Blue
        $profiles = "--profile cloud"
        $label = "Cloud Tier"
    }
    "Q" {
        Write-Host "Exiting." -ForegroundColor DarkGray
        exit 0
    }
    default {
        Write-Host "[!] Invalid choice. Starting Standard Lab by default." -ForegroundColor Yellow
        $profiles = "--profile core"
        $label = "Standard Lab (default)"
    }
}

Write-Host ""
Write-Host "[*] Mode: $label" -ForegroundColor Cyan
Write-Host "[*] Working directory: $labDir"
Write-Host "[*] Running: docker compose $profiles up -d --build"
Write-Host ""

Push-Location $labDir
$cmd = "docker compose $profiles up -d --build 2>&1"
Invoke-Expression $cmd
$exitCode = $LASTEXITCODE
Pop-Location

Write-Host ""
if ($exitCode -eq 0) {
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║  ✅  Lab is Starting! Containers are being created...         ║" -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Access Points:" -ForegroundColor Yellow
    Write-Host "  Corporate Portal:   http://localhost:80       (admin / NexusTechAdmin2026!)"
    Write-Host "  Corporate Webmail:  http://localhost:8025"
    Write-Host "  SSH Bastion:        ssh devops-remote@localhost -p 2222"

    if ($profiles -match "enterprise") {
        Write-Host "  Grafana NMS:        http://localhost:3000     (nexus_nms_admin / NMS@Nexus2026!)"
        Write-Host "  ZTNA Info:          http://localhost:8443"
        Write-Host "  VoIP PBX:           sip:1003@localhost:5060   (password: 1234)"
        Write-Host "  IP Cameras RTSP:    rtsp://localhost:8554/nexus-lobby"
        Write-Host "  IP Cameras HLS:     http://localhost:8888/nexus-lobby/"
    }
    if ($profiles -match "cloud") {
        Write-Host "  Cloud Microservice: http://localhost:8090"
        Write-Host "  SaaS SSO Portal:    http://localhost:8443"
    }
    Write-Host ""
    Write-Host "  Student Entry Points:" -ForegroundColor Yellow
    Write-Host "  [Black-Box]   docker exec -it nexus-attacker-box bash"
    Write-Host "  [Gray-Box]    docker exec -it nexus-pc-dev-01 bash"
    Write-Host "  [Blue-Team]   docker exec -it nexus-corp-siem-soc bash"
    Write-Host ""
    Write-Host "  Run health check: .\scripts\check-health.ps1" -ForegroundColor Cyan
} else {
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Red
    Write-Host "║  ❌  Startup failed! Check errors above.                      ║" -ForegroundColor Red
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Red
    Write-Host "  Try: docker compose $profiles logs" -ForegroundColor Yellow
}
