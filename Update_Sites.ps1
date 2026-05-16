# Update_Sites.ps1
# This script rebuilds all projects and updates the publish folder

Write-Host "--- Updating API ---"
# Use App_Offline.htm to release file locks in IIS
$apiPublishPath = "publish/api"
$appOfflineFile = "$apiPublishPath/App_Offline.htm"
if (-not (Test-Path $apiPublishPath)) { New-Item -ItemType Directory -Path $apiPublishPath -Force }
"<h1>Site Offline for Maintenance</h1>" | Out-File -FilePath $appOfflineFile -Encoding utf8

dotnet publish src/TescoClone.API/TescoClone.API.csproj -c Release -o $apiPublishPath

# Bring API back online
if (Test-Path $appOfflineFile) { Remove-Item $appOfflineFile -Force }

Write-Host "`n--- Updating Storefront ---"
Set-Location frontend/tesco-storefront
npm run build
Set-Location ../..
# Create directory if it doesn't exist
if (-not (Test-Path "publish/web")) { New-Item -ItemType Directory -Path "publish/web" -Force }
# Clear old files
Remove-Item -Path "publish/web/*" -Recurse -Force -ErrorAction SilentlyContinue
# Copy new files
Copy-Item -Path "frontend/tesco-storefront/dist/tesco-storefront/browser/*" -Destination "publish/web" -Recurse -Force

Write-Host "`n--- Updating Admin ---"
Set-Location frontend/tesco-admin
npm run build
Set-Location ../..
# Create directory if it doesn't exist
if (-not (Test-Path "publish/admin")) { New-Item -ItemType Directory -Path "publish/admin" -Force }
# Clear old files
Remove-Item -Path "publish/admin/*" -Recurse -Force -ErrorAction SilentlyContinue
# Copy new files
Copy-Item -Path "frontend/tesco-admin/dist/tesco-admin/browser/*" -Destination "publish/admin" -Recurse -Force

Write-Host "`n--- PUBLISH COMPLETE ---"
Write-Host "API: http://192.168.10.22:8081"
Write-Host "Web: http://192.168.10.22:8082"
Write-Host "Admin: http://192.168.10.22:8083"
