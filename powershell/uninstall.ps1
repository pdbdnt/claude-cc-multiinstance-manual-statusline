# Claude Code Multi-Instance Toolkit - PowerShell Uninstaller
#
# This script removes the CC functions (sl and cc) from your PowerShell profile.
# It will:
# 1. Locate your PowerShell profile
# 2. Create a backup before removal
# 3. Remove the CC functions section
# 4. Optionally restore from a previous backup
#
# Usage:
#   .\uninstall.ps1
#
# Author: Dennis
# License: MIT

# ==============================================================================
# Configuration
# ==============================================================================

$ErrorActionPreference = "Stop"

# ==============================================================================
# Helper Functions
# ==============================================================================

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✓ $Message" "Green"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "✗ $Message" "Red"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ $Message" "Cyan"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠ $Message" "Yellow"
}

# ==============================================================================
# Main Uninstallation
# ==============================================================================

Write-ColorOutput "`n=== Claude Code Multi-Instance Toolkit Uninstaller ===" "Magenta"
Write-ColorOutput "This will remove the 'sl' and 'cc' functions from your PowerShell profile.`n" "White"

# 1. Detect PowerShell profile location
Write-Info "Detecting PowerShell profile location..."
$profilePath = $PROFILE

if (-not $profilePath) {
    Write-Error "Could not detect PowerShell profile location."
    exit 1
}

if (-not (Test-Path $profilePath)) {
    Write-Warning "PowerShell profile not found at: $profilePath"
    Write-Info "Nothing to uninstall."
    exit 0
}

Write-Success "Profile found: $profilePath"

# 2. Read current profile content
$profileContent = Get-Content $profilePath -Raw

# 3. Check if CC functions are installed
if ($profileContent -notmatch "Claude Code Multi-Instance Toolkit") {
    Write-Warning "CC functions do not appear to be installed in your profile."
    Write-Info "No installation markers found."

    # Check for functions anyway
    if ($profileContent -match "function cc \{" -or $profileContent -match "function sl \{") {
        Write-Warning "However, 'cc' or 'sl' functions were found."
        $continue = Read-Host "Do you want to manually remove them? (y/n)"
        if ($continue -ne "y") {
            Write-Info "Uninstallation cancelled."
            exit 0
        }
    } else {
        Write-Info "Nothing to uninstall."
        exit 0
    }
}

# 4. Create backup before removal
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupPath = "$profilePath.backup-$timestamp"
Write-Info "Creating backup before removal..."
Copy-Item $profilePath $backupPath
Write-Success "Backup created: $backupPath"

# 5. Remove CC functions section
Write-Info "Removing CC functions from profile..."

# Remove everything between the installation markers
$pattern = "(?s)# ={70,}\s*# Claude Code Multi-Instance Toolkit.*?# End of Claude Code Multi-Instance Toolkit\s*# ={70,}\s*"
$newContent = $profileContent -replace $pattern, ""

# Fallback: Try to remove individual functions if markers not found
if ($newContent -eq $profileContent) {
    Write-Warning "Installation markers not found. Attempting manual removal..."

    # Remove function sl {...}
    $newContent = $newContent -replace "(?s)function sl \{.*?\n\}\s*", ""

    # Remove function cc {...}
    $newContent = $newContent -replace "(?s)function cc \{.*?\n\}\s*", ""

    # Remove any remaining comments about CC toolkit
    $newContent = $newContent -replace "(?m)^#.*?Claude Code Multi-Instance.*$\s*", ""
}

# 6. Write updated profile
Set-Content -Path $profilePath -Value $newContent
Write-Success "CC functions removed from profile"

# 7. Test the updated profile
Write-Info "Testing updated profile..."
try {
    . $profilePath
    Write-Success "Profile loaded successfully"
} catch {
    Write-Error "Failed to load updated profile: $_"
    Write-Warning "Restoring from backup..."
    Copy-Item $backupPath $profilePath -Force
    Write-Success "Profile restored from backup"
    Write-Info "Please check your profile manually at: $profilePath"
    exit 1
}

# 8. Verify functions are removed
$slCommand = Get-Command "sl" -ErrorAction SilentlyContinue
$ccCommand = Get-Command "cc" -ErrorAction SilentlyContinue

if ($slCommand -or $ccCommand) {
    Write-Warning "Functions 'sl' or 'cc' are still available in current session."
    Write-Info "This is expected - close and reopen PowerShell to complete removal."
} else {
    Write-Success "Functions have been removed from current session"
}

# 9. List available backups
Write-Info "Looking for previous backups..."
$backupFiles = Get-ChildItem -Path (Split-Path $profilePath -Parent) -Filter "*.backup-*" | Sort-Object LastWriteTime -Descending

if ($backupFiles.Count -gt 0) {
    Write-Info "Available backups:"
    foreach ($backup in $backupFiles) {
        Write-ColorOutput "  - $($backup.Name)" "Gray"
    }
    Write-Info "To restore a backup: Copy-Item <backup-file> $profilePath -Force"
}

# 10. Display completion message
Write-ColorOutput "`n=== Uninstallation Complete! ===" "Green"
Write-ColorOutput "`nThe 'sl' and 'cc' functions have been removed from your profile." "White"

Write-ColorOutput "`nNext steps:" "White"
Write-ColorOutput "1. Close and reopen PowerShell to complete removal" "White"
Write-ColorOutput "2. If you want to restore, use the backup at: $backupPath`n" "White"

Write-ColorOutput "Uninstallation log:" "Gray"
Write-ColorOutput "  Profile: $profilePath" "Gray"
Write-ColorOutput "  Backup: $backupPath`n" "Gray"
