# ============================================================
# Flutter Hard Clean Script (Windows)
# Repo-safe | One-click | Deterministic
# ============================================================

Write-Host "=== Nexus Flutter Hard Clean ===" -ForegroundColor Cyan

# --- Step 1: Kill known lock-holding processes ---
$processes = @(
    "flutter",
    "dart",
    "flutter_tester",
    "chrome",
    "msbuild",
    "java",
    "gradle",
    "emulator"
)

Write-Host "Killing background processes..." -ForegroundColor Yellow
foreach ($proc in $processes) {
    taskkill /F /IM "$proc.exe" 2>$null | Out-Null
}

# --- Step 2: Ensure we are in Flutter client directory ---
$clientPath = "C:\nexus-core\client"

if (-Not (Test-Path $clientPath)) {
    Write-Host "ERROR: Client path not found: $clientPath" -ForegroundColor Red
    exit 1
}

Set-Location $clientPath

# --- Step 3: Remove Flutter ephemeral folders ---
$ephemeralPaths = @(
    "ios\Flutter\ephemeral",
    "linux\flutter\ephemeral",
    "macos\Flutter\ephemeral",
    "windows\flutter\ephemeral",
    "build",
    ".dart_tool"
)

Write-Host "Removing ephemeral directories..." -ForegroundColor Yellow
foreach ($path in $ephemeralPaths) {
    if (Test-Path $path) {
        Write-Host " - Deleting $path"
        Remove-Item -Recurse -Force $path -ErrorAction SilentlyContinue
    }
}

# --- Step 4: Flutter clean + pub get ---
Write-Host "Running flutter clean..." -ForegroundColor Yellow
flutter clean

Write-Host "Running flutter pub get..." -ForegroundColor Yellow
flutter pub get

# --- Done ---
Write-Host "=== Flutter workspace fully reset ===" -ForegroundColor Green
