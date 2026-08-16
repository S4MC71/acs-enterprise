Push-Location (Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path -Parent)

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║  ⚠️  NEXUS LAB RESET — This will stop and remove all  ║" -ForegroundColor Red
Write-Host "║      lab containers, networks, and volumes.            ║" -ForegroundColor Red
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Red
Write-Host ""
$confirm = Read-Host "Type 'yes' to confirm full reset"

if ($confirm -eq "yes") {
    Write-Host "[*] Stopping all profile containers..." -ForegroundColor Yellow
    docker compose --profile core --profile enterprise --profile cloud down -v --remove-orphans
    Write-Host "[*] Removing Nexus lab networks..."
    docker network prune -f | Out-Null
    Write-Host "[+] Lab reset complete. Run start-lab.ps1 to rebuild." -ForegroundColor Green
} else {
    Write-Host "[!] Reset cancelled." -ForegroundColor DarkGray
}

Pop-Location
