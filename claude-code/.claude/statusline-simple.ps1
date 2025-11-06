# Claude Code Statusline Script
#
# This script generates a custom statusline for Claude Code CLI that displays:
# 1. Project path (last 2 directory segments: \parent\project)
# 2. Manual status text (set via /statuslineupdate command)
# 3. AI model name (if ccusage tool is installed)
# 4. Current plan/task (parsed from transcript)
#
# Output format:
#   \apps\MyProject | [M] Manual text | Sonnet 4.5 | Plan >> Active task
#
# Dependencies:
# - PowerShell 5.1+ (Windows built-in)
# - ccusage (optional) - For AI model display
# - PANE_NAME env var (optional) - For pane-specific manual status
#
# Author: Dennis
# License: MIT

try {
    # Read JSON input from Claude Code via stdin
    $inputData = [Console]::In.ReadToEnd()
    $currentPath = "\unknown"

    # ==============================================================================
    # 1. Extract Project Path (last 2 directory segments)
    # ==============================================================================
    # Shows: \parent\project instead of full path
    # Example: C:\Users\denni\apps\zWoofi → \apps\zWoofi

    if ($inputData) {
        try {
            $json = $inputData | ConvertFrom-Json
            if ($json -and $json.workspace -and $json.workspace.current_dir) {
                $path = $json.workspace.current_dir

                # Normalize path separators and extract last 2 segments
                $normalizedPath = $path -replace '/', '\'
                $pathParts = @($normalizedPath -split '\\' | Where-Object { $_.Length -gt 0 })

                if ($pathParts.Count -ge 2) {
                    $parent = $pathParts[$pathParts.Count - 2]
                    $project = $pathParts[$pathParts.Count - 1]
                    $currentPath = "\$parent\$project"
                } elseif ($pathParts.Count -eq 1) {
                    # Only one segment (e.g., root directory)
                    $currentPath = "\$($pathParts[0])"
                }
            }
        } catch {
            $currentPath = "\json-error"
        }
    }

    # ==============================================================================
    # 2. Get AI Model Name (Optional - requires ccusage)
    # ==============================================================================
    # Uses ccusage CLI tool to extract current model from transcript
    # Install: npm install -g ccusage
    # If not installed, this section is skipped (no error)

    $modelInfo = ""
    try {
        if ($json.session_id -or $json.transcript_path) {
            $ccusageOutput = $inputData | ccusage statusline 2>$null
            if ($ccusageOutput -and $ccusageOutput -match '^\s*([^|]+)') {
                $modelName = $matches[1].Trim()
                $modelInfo = " | $modelName"
            }
        }
    } catch {
        # ccusage not installed or error - skip this section
    }

    # ==============================================================================
    # 3. Get Manual Status Text (Optional - via /statuslineupdate command)
    # ==============================================================================
    # Reads from .statusline-manual-<identifier> files created by /statuslineupdate
    #
    # Priority 1: Pane-specific file (if PANE_NAME env var set)
    #   Example: .statusline-manual-CC-20251106-143022
    #
    # Priority 2: Session-specific file (fallback)
    #   Example: .statusline-manual-abc123def
    #
    # Display format: [M] Manual text here

    $manualStatus = ""
    if ($json -and $json.workspace -and $json.workspace.current_dir) {
        # Priority 1: Check for pane-based file (if PANE_NAME env var exists)
        if ($env:PANE_NAME) {
            $manualFile = Join-Path $json.workspace.current_dir ".statusline-manual-$env:PANE_NAME"
        }
        # Priority 2: Fall back to session-based file
        elseif ($json.session_id) {
            $manualFile = Join-Path $json.workspace.current_dir ".statusline-manual-$($json.session_id)"
        }

        if ($manualFile -and (Test-Path $manualFile)) {
            try {
                $manualText = Get-Content $manualFile -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($manualText) {
                    $manualText = $manualText.Trim()
                    # Truncate if too long
                    if ($manualText.Length -gt 30) {
                        $manualText = $manualText.Substring(0, 27) + "..."
                    }
                    $manualStatus = " | [M] $manualText"
                }
            } catch {
                # Manual file read error - ignore
            }
        }
    }

    # ==============================================================================
    # 4. Get Plan/Task from Transcript (Automatic)
    # ==============================================================================
    # Parses transcript.jsonl to extract:
    # - TodoWrite tool calls → Shows "Plan name >> Active task"
    # - Task tool calls → Shows "[A] Task description" (agent)
    # - Working indicators → Shows "[Working...]"
    # - Fallback → Shows "Idle"

    $planStatus = " | Idle"

    try {
        if ($json -and $json.transcript_path -and (Test-Path $json.transcript_path)) {
            $transcriptContent = Get-Content $json.transcript_path -Raw -Encoding UTF8

            # Method 1: Look for TodoWrite (matches "name":"TodoWrite")
            # This is the most reliable method for task tracking
            $todoPattern = '"name"\s*:\s*"TodoWrite"[\s\S]*?"todos"\s*:\s*\[[\s\S]*?\]'
            $todoMatches = [regex]::Matches($transcriptContent, $todoPattern)

            if ($todoMatches.Count -gt 0) {
                # Get the last (most recent) match
                $lastMatch = $todoMatches[$todoMatches.Count - 1].Value

                # Extract just the todos array
                if ($lastMatch -match '"todos"\s*:\s*(\[[\s\S]*?\])') {
                    $todosJson = $matches[1]
                    $todos = $todosJson | ConvertFrom-Json -ErrorAction SilentlyContinue

                    if ($todos -and $todos.Count -gt 0) {
                        # Get plan name from first todo
                        $planName = ""
                        if ($todos[0].content) {
                            $planName = $todos[0].content
                            if ($planName.Length -gt 18) {
                                $planName = $planName.Substring(0, 15) + "..."
                            }
                        }

                        # Find in_progress task
                        foreach ($todo in $todos) {
                            if ($todo.status -eq "in_progress") {
                                $activeTask = $todo.activeForm
                                if ($activeTask.Length -gt 25) {
                                    $activeTask = $activeTask.Substring(0, 22) + "..."
                                }

                                if ($planName) {
                                    $planStatus = " | $planName >> $activeTask"
                                } else {
                                    $planStatus = " | >> $activeTask"
                                }
                                break
                            }
                        }
                    }
                }
            }

            # Method 2: Look for Task tool calls (fallback if no TodoWrite found)
            if ($planStatus -eq " | Idle") {
                $taskPattern = '"tool"\s*:\s*"Task"[\s\S]{0,500}?"description"\s*:\s*"([^"]+)"'
                $taskMatches = [regex]::Matches($transcriptContent, $taskPattern)
                if ($taskMatches.Count -gt 0) {
                    $taskDesc = $taskMatches[$taskMatches.Count - 1].Groups[1].Value
                    if ($taskDesc.Length -gt 35) {
                        $taskDesc = $taskDesc.Substring(0, 32) + "..."
                    }
                    $planStatus = " | [A] $taskDesc"
                }
            }

            # Method 3: Look for working indicators (fallback)
            if ($planStatus -eq " | Idle") {
                if ($transcriptContent -match '(?:Perusing|Sautéing|Embellishing|Unfurling)\.\.\.') {
                    $planStatus = " | [Working...]"
                }
            }
        }
    } catch {
        $planStatus = " | parse-error"
    }

    # ==============================================================================
    # 5. Build and Output Final Statusline
    # ==============================================================================
    # Format: <path> | [M] <manual> | <model> | <plan/task>
    # Example: \apps\zWoofi | [M] Auth debug | Sonnet 4.5 | Fix bug >> Testing

    Write-Output "$currentPath$manualStatus$modelInfo$planStatus"

} catch {
    # Catch-all error handler
    Write-Output "\error"
}
