# IIS_Setup.ps1
# This script configures IIS sites for the Tesco Clone application.
# Run this script in PowerShell as Administrator.

# Check for Administrator privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator."
    exit
}

# 1. Enable IIS and ASP.NET Core module if not enabled
Write-Host "--- Enabling IIS Features ---"
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-WebServerRole" -All
Enable-WindowsOptionalFeature -Online -FeatureName "IIS-ASPNET45" -All

# 2. Import WebAdministration module
Import-Module WebAdministration

# 3. Create Application Pools
Write-Host "`n--- Creating Application Pools ---"
foreach ($pool in @("TescoAPI", "TescoWeb", "TescoAdmin")) {
    if (-not (Test-Path "IIS:\AppPools\$pool")) {
        New-Item "IIS:\AppPools\$pool"
        Write-Host "Created AppPool: $pool"
    }
}

# Set App Pool to No Managed Code (for .NET Core)
Set-ItemProperty "IIS:\AppPools\TescoAPI" -Name "managedRuntimeVersion" -Value ""

# 4. Create Sites
Write-Host "`n--- Creating Sites ---"
$baseDir = "E:\Tesco\Tesco-clone\publish"

# API (Port 8081)
if (-not (Get-Website -Name "TescoAPI")) {
    New-Website -Name "TescoAPI" -Port 8081 -PhysicalPath "$baseDir\api" -ApplicationPool "TescoAPI"
    Write-Host "Created Site: TescoAPI (Port 8081)"
}

# Web (Port 8082)
if (-not (Get-Website -Name "TescoWeb")) {
    New-Website -Name "TescoWeb" -Port 8082 -PhysicalPath "$baseDir\web" -ApplicationPool "TescoWeb"
    Write-Host "Created Site: TescoWeb (Port 8082)"
}

# Admin (Port 8083)
if (-not (Get-Website -Name "TescoAdmin")) {
    New-Website -Name "TescoAdmin" -Port 8083 -PhysicalPath "$baseDir\admin" -ApplicationPool "TescoAdmin"
    Write-Host "Created Site: TescoAdmin (Port 8083)"
}

Write-Host "`n--- SETUP COMPLETE ---"
Write-Host "You can now access the sites at:"
Write-Host "API: http://localhost:8081"
Write-Host "Web: http://localhost:8082"
Write-Host "Admin: http://localhost:8083"
