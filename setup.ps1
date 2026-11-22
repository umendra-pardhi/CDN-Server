
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===================================="
Write-Host "       SIMPLE CDN INSTALLER"
Write-Host "===================================="

# Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is not installed. Install Docker Desktop first."
}

docker info | Out-Null

if ($LASTEXITCODE -ne 0) {
    throw "Docker Desktop is not running."
}

# Create directories
New-Item -ItemType Directory -Force -Path "static" | Out-Null

# Build and start containers
Write-Host ""
Write-Host "Building CDN containers..."

docker compose up -d --build --remove-orphans

if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose failed."
}

Write-Host ""
Write-Host "===================================="
Write-Host "       CDN STARTED SUCCESSFULLY"
Write-Host "===================================="

Write-Host "CDN URL: http://localhost:8080"

Write-Host ""
Write-Host "Example download:"
Write-Host "curl.exe http://localhost:8080/logo.png -o logo.png"

Write-Host ""
Write-Host "View logs:"
Write-Host "docker compose logs -f"

Write-Host ""
Write-Host "Stop CDN:"
Write-Host "docker compose down"

Write-Host "===================================="
