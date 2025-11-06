# Claude Code Multi-Instance Toolkit - PowerShell Installer
#
# This script installs the CC functions (sl and cc) to your PowerShell profile.
# It will:
# 1. Detect your PowerShell profile location
# 2. Create a backup of your existing profile
# 3. Append the CC functions to your profile
# 4. Validate Claude CLI installation
#
# Usage:
#   .\install.ps1
#
# Author: Dennis
# License: MIT

# ==============================================================================
# Configuration
# ==============================================================================

$ErrorActionPreference = "Stop"
$FunctionsFile = Join-Path $PSScriptRoot "cc-functions.ps1"

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
# Main Installation
# ==============================================================================

Write-ColorOutput "`n=== Claude Code Multi-Instance Toolkit Installer ===" "Magenta"
Write-ColorOutput "This will install the 'sl' and 'cc' functions to your PowerShell profile.`n" "White"

# 1. Check if cc-functions.ps1 exists
if (-not (Test-Path $FunctionsFile)) {
    Write-Error "Could not find cc-functions.ps1 in the same directory as this installer."
    Write-Info "Expected location: $FunctionsFile"
    exit 1
}
Write-Success "Found cc-functions.ps1"

# 2. Check if Claude CLI is installed
Write-Info "Checking for Claude CLI installation..."
$claudeCommand = Get-Command "claude" -ErrorAction SilentlyContinue

if (-not $claudeCommand) {
    Write-Warning "Claude CLI not found in PATH."
    Write-Info "The CC functions require Claude CLI to be installed."
    Write-Info "Download from: https://claude.ai/download"
    $continue = Read-Host "`nContinue anyway? (y/n)"
    if ($continue -ne "y") {
        Write-Info "Installation cancelled."
        exit 0
    }
} else {
    Write-Success "Claude CLI found at: $($claudeCommand.Source)"
}

# 3. Detect PowerShell profile location
Write-Info "Detecting PowerShell profile location..."
$profilePath = $PROFILE

if (-not $profilePath) {
    Write-Error "Could not detect PowerShell profile location."
    Write-Info "Please set `$PROFILE variable manually."
    exit 1
}

Write-Success "Profile location: $profilePath"

# 4. Create profile directory if it doesn't exist
$profileDir = Split-Path $profilePath -Parent
if (-not (Test-Path $profileDir)) {
    Write-Info "Creating profile directory: $profileDir"
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
    Write-Success "Profile directory created"
}

# 5. Create backup of existing profile
if (Test-Path $profilePath) {
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$profilePath.backup-$timestamp"
    Write-Info "Creating backup of existing profile..."
    Copy-Item $profilePath $backupPath
    Write-Success "Backup created: $backupPath"
} else {
    Write-Info "No existing profile found. A new one will be created."
}

# 6. Check if functions are already installed
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath -Raw
    if ($profileContent -match "function cc \{" -or $profileContent -match "function sl \{") {
        Write-Warning "It looks like 'cc' or 'sl' functions are already in your profile."
        $continue = Read-Host "Do you want to append them anyway? This may create duplicates. (y/n)"
        if ($continue -ne "y") {
            Write-Info "Installation cancelled."
            exit 0
        }
    }
}

# 7. Append functions to profile
Write-Info "Installing CC functions to profile..."

# Read the functions file
$functionsContent = Get-Content $FunctionsFile -Raw

# Append to profile with clear markers
$installMarker = @"

# ==============================================================================
# Claude Code Multi-Instance Toolkit
# Installed: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
# Source: https://github.com/pdbdnt/claude-cc-multiinstance-manual-statusline
# ==============================================================================

$functionsContent

# ==============================================================================
# End of Claude Code Multi-Instance Toolkit
# ==============================================================================
"@

Add-Content -Path $profilePath -Value $installMarker
Write-Success "Functions installed to profile"

# 8. Test by dot-sourcing the profile
Write-Info "Testing installation..."
try {
    . $profilePath
    Write-Success "Profile loaded successfully"
} catch {
    Write-Error "Failed to load profile: $_"
    Write-Info "You may need to fix syntax errors in: $profilePath"
    exit 1
}

# 9. Verify functions are available
$slCommand = Get-Command "sl" -ErrorAction SilentlyContinue
$ccCommand = Get-Command "cc" -ErrorAction SilentlyContinue

if ($slCommand -and $ccCommand) {
    Write-Success "Functions 'sl' and 'cc' are now available"
} else {
    Write-Warning "Functions may not be loaded correctly."
    Write-Info "Try closing and reopening PowerShell."
}

# 10. Display usage instructions
Write-ColorOutput "`n=== Installation Complete! ===" "Green"
Write-ColorOutput "`nThe following functions are now available:" "White"
Write-ColorOutput "  sl <name>  - Set manual session identifier" "Cyan"
Write-ColorOutput "  cc         - Launch Claude Code with session tracking" "Cyan"

Write-ColorOutput "`nExample usage:" "White"
Write-ColorOutput "  sl FixingAuthBug    # Set identifier" "Yellow"
Write-ColorOutput "  cc                  # Launch Claude Code" "Yellow"

Write-ColorOutput "`nNext steps:" "White"
Write-ColorOutput "1. Close and reopen PowerShell (or run: . `$PROFILE)" "White"
Write-ColorOutput "2. Test with: sl TestSession" "White"
Write-ColorOutput "3. Launch Claude Code with: cc" "White"
Write-ColorOutput "4. (Optional) Configure Claude Code statusline - see ../claude-code/STATUSLINE.md`n" "White"

# 11. Execution policy reminder
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Warning "Your execution policy is set to 'Restricted'."
    Write-Info "You may need to change it to run the CC functions."
    Write-Info "Run: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser"
}

Write-ColorOutput "Installation log saved to: $profilePath" "Gray"
Write-ColorOutput "Backup saved to: $backupPath`n" "Gray"
