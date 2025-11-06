# Claude Code Multi-Instance Session Management Functions
#
# These functions help manage multiple Claude Code CLI instances by:
# 1. Setting manual session identifiers (sle function)
# 2. Auto-generating timestamped session IDs (cc function)
# 3. Preserving directory context across sessions
#
# Usage:
#   sl MySessionName    # Set manual identifier
#   cc                  # Launch Claude Code with session tracking
#
# Author: Dennis
# License: MIT

# ==============================================================================
# SLE Function - Set Label for Environment
# ==============================================================================
# Sets a manual identifier in the PANE_NAME environment variable.
# This identifier appears in your Claude Code statusline, helping you
# distinguish between multiple terminal instances.
#
# Usage Examples:
#   sl FixingAuthBug           # Set identifier
#   sl                         # Show current identifier
#
# The PANE_NAME variable is used by:
# - Claude Code statusline (if configured)
# - Terminal multiplexers (tmux, etc.)
# - Custom scripts that need session context

function sl {
    param([string]$name)

    if ($name) {
        # Set the environment variable (uppercase for consistency)
        $env:PANE_NAME = $name.ToUpper()

        # Visual feedback
        Write-Host 'Pane name set to: ' -NoNewline -ForegroundColor Green
        Write-Host $env:PANE_NAME -ForegroundColor Green
        Write-Host ('$env:PANE_NAME = ' + $env:PANE_NAME) -ForegroundColor Cyan
    } else {
        # Show current identifier or help text
        if ($env:PANE_NAME) {
            Write-Host ('Current pane: ' + $env:PANE_NAME) -ForegroundColor Cyan
        } else {
            Write-Host 'No pane name set. Usage: sl <name>' -ForegroundColor Yellow
        }
    }
}

# ==============================================================================
# CC Function - Claude Code Wrapper with Session Tracking
# ==============================================================================
# Wraps the 'claude' CLI command with automatic session management:
# 1. Preserves current directory (returns you to where you started)
# 2. Generates unique timestamped session ID
# 3. Sets PANE_NAME for statusline integration
# 4. Passes all arguments to Claude CLI
#
# The timestamp format (yyyyMMdd-HHmmss) ensures:
# - Unique session IDs (no collisions)
# - Chronological sorting
# - Easy identification in logs
#
# Usage Examples:
#   cc                         # Launch Claude Code
#   cc --help                  # Pass arguments through
#   cc --model opus            # All flags supported
#
# Directory Preservation:
# - Uses Push-Location/Pop-Location stack
# - Safe even if Claude crashes
# - Restores directory after exit

function cc {
    # Save current directory to location stack
    # This ensures we return here even if Claude changes directories
    Push-Location $PWD

    # Generate unique timestamped session identifier
    # Format: CC-20251106-143022
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $paneId = "CC-$timestamp"

    # Set the pane identifier using sle function
    # This provides visual feedback and sets PANE_NAME
    sl $paneId

    # Also set as environment variable directly (redundant but explicit)
    # Some scripts may check this directly
    $env:PANE_NAME = $paneId.ToUpper()

    # Launch Claude Code CLI with:
    # - --dangerously-skip-permissions: Skip permission prompts (convenience)
    # - @args: Forward all arguments passed to cc function
    #
    # NOTE: Remove --dangerously-skip-permissions if you prefer permission checks
    claude --dangerously-skip-permissions @args

    # Restore original directory from location stack
    # Executes even if Claude exits with error
    Pop-Location
}

# ==============================================================================
# Alias Setup (Optional)
# ==============================================================================
# You can create shorter aliases if desired:
# Set-Alias -Name sle -Value sl
# Set-Alias -Name setlabel -Value sl

# ==============================================================================
# Integration with Claude Code Statusline
# ==============================================================================
# For the statusline to display PANE_NAME, you need:
# 1. Claude Code statusline configuration (see claude-code/.claude/ folder)
# 2. The statusline script must read $env:PANE_NAME
#
# Example statusline output:
#   \apps\MyProject | [M] CC-20251106-143022 | Sonnet 4.5 | Task name
#
# Where:
#   \apps\MyProject     = Current project path
#   CC-20251106-143022  = Auto-generated session ID (from cc function)
#   Sonnet 4.5          = Current AI model
#   Task name           = Current task/plan
#
# See ../claude-code/STATUSLINE.md for setup instructions

# ==============================================================================
# Notes
# ==============================================================================
# - PANE_NAME persists for the entire PowerShell session
# - Each new terminal window gets a new PANE_NAME
# - You can override with: sl CustomName
# - To clear: Remove-Item Env:\PANE_NAME
# - Compatible with: PowerShell 5.1+ (Windows built-in)
