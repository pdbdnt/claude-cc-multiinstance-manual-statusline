#!/bin/bash
# Clear manual statusline text
#
# This command removes the .statusline-manual-<identifier> file created by
# /statuslineupdate, clearing the manual status text from your statusline.
#
# Usage:
#   /statuslineclear
#
# The identifier is determined by:
#   1. PANE_NAME environment variable (if set)
#   2. Generic file (fallback)
#
# Author: Dennis
# License: MIT

# Determine which file to clear based on PANE_NAME
if [ -n "$PANE_NAME" ]; then
    # Clear pane-specific file
    SUFFIX="$PANE_NAME"
    FILE=".statusline-manual-$SUFFIX"
else
    # Clear generic file
    FILE=".statusline-manual"
fi

# Remove the file if it exists
if [ -f "$FILE" ]; then
    rm "$FILE"
    echo "✓ Manual statusline text cleared"
    if [ -n "$PANE_NAME" ]; then
        echo "  Pane: $PANE_NAME"
    fi
    echo "  File: $FILE"
else
    echo "No manual statusline text to clear"
    if [ -n "$PANE_NAME" ]; then
        echo "  Checked for: $FILE"
    else
        echo "  Tip: Set PANE_NAME env var for pane-specific status"
    fi
fi
