
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

# Generate API key if .env doesn't exist
if (-not (Test-Path ".env")) {

    $bytes = New-Object byte[] 32

    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()

    try {
        $rng.GetBytes($bytes)
    }
    finally {
        $rng.Dispose()
    }

    $key = [Convert]::ToHexString($bytes).ToLowerInvariant()

    Set-Content -Path ".env" -Value "CDN_API_KEY=$key" -NoNewline

    Write-Host "Generated new API key."
}
else {
    Write-Host "Existing API key preserved."
}

# Build and start containers
Write-Host ""
Write-Host "Building CDN containers..."

docker compose up -d --build

if ($LASTEXITCODE -ne 0) {
    throw "Docker Compose failed."
}

# Read API key
$envContent = Get-Content ".env"

$apiKeyLine = $envContent |
    Where-Object { $_ -match '^CDN_API_KEY=' } |
    Select-Object -First 1

$apiKey = $apiKeyLine -replace '^CDN_API_KEY=', ''

Write-Host ""
Write-Host "===================================="
Write-Host "       CDN STARTED SUCCESSFULLY"
Write-Host "===================================="

Write-Host "CDN URL: http://localhost:8080"
Write-Host "API Key: $apiKey"

Write-Host ""
Write-Host "Example download:"
Write-Host "curl.exe -H `"X-API-Key: YOUR_KEY`" http://localhost:8080/logo.png -o logo.png"

Write-Host ""
Write-Host "View logs:"
Write-Host "docker compose logs -f"

Write-Host ""
Write-Host "Stop CDN:"
Write-Host "docker compose down"

Write-Host "===================================="
