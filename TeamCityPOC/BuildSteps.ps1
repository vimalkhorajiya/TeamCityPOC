# -----------------------------
# .NET MVC Deployment Script
# -----------------------------

# -----------------------------
# CONFIGURATION
# -----------------------------
$DeploymentPath     = "D:\Published_Builds\TeamCity"       # IIS site folder
$AppPoolName        = "TeamCityPOC"                        # IIS App Pool name
$CurrentBuildBackup = "D:\Published_Builds\Backup\TeamCity"  # Backup folder
$SourcePath         = "%teamcity.build.checkoutDir%\publish" # TeamCity publish folder

# Exclude these files/folders from deletion
$ExcludeNames = @(".vs", ".vscode", "web.config", ".gitignore", ".env")

# -----------------------------
# STEP 1: Backup Current Build
# -----------------------------
$stamp = "TeamCityPOC_" + (Get-Date -Format "yyyyMMddHHmmss")
$backupPath = Join-Path $CurrentBuildBackup $stamp

Write-Host "Step 1: Backing up current deployment to $backupPath..."
if (!(Test-Path $backupPath)) { New-Item -Path $backupPath -ItemType Directory -Force }
Copy-Item -Path $DeploymentPath -Destination $backupPath -Recurse -Force

# -----------------------------
# STEP 2: Stop IIS App Pool
# -----------------------------
Write-Host "Step 2: Stopping IIS App Pool: $AppPoolName..."
Import-Module WebAdministration
Stop-WebAppPool -Name $AppPoolName

# -----------------------------
# STEP 3: Clean Old Deployment
# -----------------------------
Write-Host "Step 3: Cleaning old deployment (excluding top-level files/folders)..."
Get-ChildItem -Path $DeploymentPath | Where-Object { $ExcludeNames -notcontains $_.Name } |
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue

# -----------------------------
# STEP 4: Copy New Build
# -----------------------------
Write-Host "Step 4: Copying new build from $SourcePath to $DeploymentPath..."
Get-ChildItem -Path $SourcePath | Where-Object { $ExcludeNames -notcontains $_.Name } |
    Copy-Item -Destination $DeploymentPath -Recurse -Force

# -----------------------------
# STEP 5: Start IIS App Pool
# -----------------------------
Write-Host "Step 5: Starting IIS App Pool: $AppPoolName..."
Start-WebAppPool -Name $AppPoolName

Write-Host "Deployment completed successfully!"
