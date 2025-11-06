#!/bin/bash
# Set manual statusline text
#
# This command creates a .statusline-manual-<identifier> file that the
# statusline script reads and displays as: [M] Your custom text
#
# Usage:
#   /statuslineupdate Working on authentication
#   /statuslineupdate Debugging API calls
#   /statuslineupdate Feature X - Testing
#
# The identifier is determined by:
#   1. PANE_NAME environment variable (if set) - Recommended for multi-instance
#   2. Claude session ID (fallback)
#
# Integration with CC alias:
#   When you use the 'cc' PowerShell function, it sets PANE_NAME automatically:
#     cc                        # Sets PANE_NAME=CC-20251106-143022
#     /statuslineupdate My task # Creates .statusline-manual-CC-20251106-143022
#
# Manual PANE_NAME (for advanced users):
#   export PANE_NAME="myPane"
#   /statuslineupdate My task  # Creates .statusline-manual-MYPANE
#
# Author: Dennis
# License: MIT

# Get all arguments as the manual text
MANUAL_TEXT="$*"

if [ -z "$MANUAL_TEXT" ]; then
    echo "Usage: /statuslineupdate <your custom text>"
    echo ""
    echo "Examples:"
    echo "  /statuslineupdate Working on auth bug"
    echo "  /statuslineupdate Feature X - Testing"
    echo ""
    exit 1
fi

# Determine the file suffix based on PANE_NAME or session ID
if [ -n "$PANE_NAME" ]; then
    # Use PANE_NAME if set (from CC alias or manually)
    SUFFIX="$PANE_NAME"
    FILE=".statusline-manual-$SUFFIX"
else
    # Fallback to generic file (will work but not pane-specific)
    FILE=".statusline-manual"
    echo "⚠ PANE_NAME not set - using generic file"
    echo "  For pane-specific status, use 'cc' command or set PANE_NAME env var"
fi

# Write to file in current directory
echo "$MANUAL_TEXT" > "$FILE"

echo "✓ Manual statusline text set to: $MANUAL_TEXT"
if [ -n "$PANE_NAME" ]; then
    echo "  Pane: $PANE_NAME"
fi
echo "  File: $FILE"
echo "  Use /statuslineclear to remove it"
