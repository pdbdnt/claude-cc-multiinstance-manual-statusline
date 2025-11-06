# Claude Code Statusline Configuration

Complete guide to setting up and using the custom Claude Code statusline that integrates with the CC PowerShell alias.

## Features

The statusline displays up to 4 components:

```
\apps\MyProject | [M] Manual text | Sonnet 4.5 | Plan >> Active task
```

1. **Project Path** - Last 2 directory segments (e.g., `\apps\zWoofi`)
2. **Manual Status** - Custom text set via `/statuslineupdate` command
3. **AI Model** - Current model (requires ccusage tool - optional)
4. **Task Tracking** - Auto-extracted from TodoWrite or Task tool calls

## Quick Start

### 1. Copy Configuration Files

Copy the `.claude` folder to your project root:

```powershell
# Copy to your project
cp -r claude-code/.claude C:\path\to\your\project\.claude
```

Your project structure should look like:

```
YourProject/
├── .claude/
│   ├── settings.json           # Statusline config
│   ├── statusline-simple.ps1   # Main script
│   └── commands/
│       ├── statuslineupdate.sh # Set manual status
│       └── statuslineclear.sh  # Clear manual status
├── src/
└── ...
```

### 2. Test the Statusline

Launch Claude Code and check if the statusline appears:

```powershell
cd C:\path\to\your\project
claude
```

You should see something like:

```
\path\project | Idle
```

### 3. Set Manual Status Text

From within Claude Code, use the `/statuslineupdate` command:

```
/statuslineupdate Working on authentication
```

The statusline updates to:

```
\path\project | [M] Working on authentication | Idle
```

### 4. Clear Manual Status

```
/statuslineclear
```

## Integration with CC PowerShell Alias

When you use the `cc` command (from `powershell/cc-functions.ps1`), it automatically:

1. Sets `PANE_NAME` environment variable with a unique timestamp
2. The statusline script detects `PANE_NAME`
3. Manual status files become pane-specific

### Example Workflow

**Terminal 1:**
```powershell
cd C:\apps\MyProject
sl FixingAuthBug        # Set PANE_NAME manually (optional)
cc                      # Launch with PANE_NAME=CC-20251106-143022
/statuslineupdate Debugging login flow
```

Statusline shows:
```
\apps\MyProject | [M] Debugging login flow | Idle
```

**Terminal 2:**
```powershell
cd C:\apps\OtherProject
cc                      # Launch with PANE_NAME=CC-20251106-143145
/statuslineupdate Testing API endpoints
```

Statusline shows:
```
\apps\OtherProject | [M] Testing API endpoints | Idle
```

Each terminal has its own manual status because `PANE_NAME` creates separate files:
- Terminal 1: `.statusline-manual-CC-20251106-143022`
- Terminal 2: `.statusline-manual-CC-20251106-143145`

## Optional: Install ccusage for Model Display

The statusline can show the current AI model (Sonnet 4.5, Opus, Haiku, etc.) if you install `ccusage`:

```powershell
npm install -g ccusage
```

After installation, the statusline automatically shows:

```
\apps\MyProject | [M] Manual text | Sonnet 4.5 | Idle
```

**Without ccusage:** Model section is omitted (no error, just hidden)

## Configuration Details

### settings.json

Minimal configuration that enables the statusline:

```json
{
  "statusLine": {
    "type": "command",
    "command": "powershell.exe -NoProfile -ExecutionPolicy Bypass -File .claude\\statusline-simple.ps1"
  }
}
```

**Notes:**
- Uses `powershell.exe` (Windows built-in)
- `-NoProfile`: Skips loading your PowerShell profile (faster startup)
- `-ExecutionPolicy Bypass`: Allows script execution
- Path uses `\\` (escaped backslash) for Windows

### statusline-simple.ps1

The main script that generates the statusline. It:

1. Reads JSON input from Claude Code via stdin
2. Extracts project path from `workspace.current_dir`
3. Checks for manual status files (pane-specific or session-specific)
4. Calls `ccusage` if available (optional)
5. Parses transcript for TodoWrite/Task tool calls
6. Outputs formatted statusline string

See inline comments in the script for detailed implementation.

### Manual Status Files

Created by `/statuslineupdate` command in your project root:

**With PANE_NAME (recommended):**
```
.statusline-manual-CC-20251106-143022
.statusline-manual-MYPANE
```

**Without PANE_NAME (fallback):**
```
.statusline-manual
```

**Format:** Plain text file containing your custom status message

**Cleanup:** These files are gitignored (see root `.gitignore`)

## Command Reference

### /statuslineupdate <text>

Set manual status text for the current pane/session.

**Examples:**
```bash
/statuslineupdate Working on auth bug
/statuslineupdate Feature X - Testing phase 2
/statuslineupdate Debugging API calls
```

**Behavior:**
- With `PANE_NAME`: Creates `.statusline-manual-<PANE_NAME>`
- Without `PANE_NAME`: Creates `.statusline-manual` (generic)

**Display:** Text appears as `[M] Your text` in statusline

**Character limit:** Truncated to 30 characters (27 + "...")

### /statuslineclear

Remove manual status text for the current pane/session.

**Examples:**
```bash
/statuslineclear
```

**Behavior:**
- Deletes the corresponding `.statusline-manual-*` file
- Statusline updates to remove `[M] ...` section

## Task Tracking (Automatic)

The statusline automatically tracks your current work by parsing the transcript:

### TodoWrite Integration

When you use the `TodoWrite` tool in Claude Code, the statusline shows:

```
Plan name >> Active task
```

**Example:**
```
Create auth flow >> Implementing login form
```

This is extracted from:
- Plan name: First todo item's `content` field
- Active task: First `in_progress` todo's `activeForm` field

### Task Tool Fallback

If no TodoWrite found, it looks for Task tool calls:

```
[A] Task description
```

**Example:**
```
[A] Investigate database performance
```

### Working Indicator Fallback

If no specific task found, it detects working indicators:

```
[Working...]
```

### Idle State

If nothing is happening:

```
Idle
```

## Troubleshooting

### Statusline Not Appearing

1. **Check settings.json exists:**
   ```powershell
   Test-Path .claude\settings.json
   ```

2. **Check PowerShell script exists:**
   ```powershell
   Test-Path .claude\statusline-simple.ps1
   ```

3. **Test script manually:**
   ```powershell
   echo '{"workspace":{"current_dir":"C:\\apps\\test"}}' | powershell -NoProfile -File .claude\statusline-simple.ps1
   ```
   Should output: `\apps\test | Idle`

### Manual Status Not Showing

1. **Check PANE_NAME is set:**
   ```powershell
   echo $env:PANE_NAME
   ```
   Should show something like: `CC-20251106-143022`

2. **Check manual file exists:**
   ```powershell
   ls .statusline-manual*
   ```

3. **Check file contents:**
   ```powershell
   cat .statusline-manual-$env:PANE_NAME
   ```

### Model Not Showing

**Expected:** Model section is optional and only appears if `ccusage` is installed.

1. **Check if ccusage is installed:**
   ```powershell
   Get-Command ccusage
   ```

2. **Install ccusage:**
   ```powershell
   npm install -g ccusage
   ```

3. **Restart Claude Code** after installing

### Permission Errors

If you get "execution policy" errors:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Path Showing as "\unknown"

This means the script couldn't parse the JSON input. Check:

1. **settings.json syntax** is valid
2. **PowerShell version** is 5.1+ (built-in on Windows)
3. **Script permissions** allow execution

## Advanced Usage

### Custom PANE_NAME

Set your own pane identifier instead of the auto-generated timestamp:

```powershell
$env:PANE_NAME = "AuthFeature"
claude
/statuslineupdate Implementing OAuth
```

Manual file becomes: `.statusline-manual-AUTHFEATURE`

### Multiple Projects with Same Pane Name

You can reuse pane names across projects safely:

```powershell
# Project A
cd C:\apps\ProjectA
$env:PANE_NAME = "MainWork"
claude

# Project B (different terminal)
cd C:\apps\ProjectB
$env:PANE_NAME = "MainWork"
claude
```

Each project gets its own `.statusline-manual-MAINWORK` file in its own directory.

### Persistent PANE_NAME Across Sessions

Add to your PowerShell profile:

```powershell
# Set default PANE_NAME for this terminal
$env:PANE_NAME = "Terminal1"
```

Now all Claude Code sessions in this terminal share the same pane identifier.

## File Reference

### Created by Setup

```
.claude/
├── settings.json              # Claude Code config
├── statusline-simple.ps1      # Main statusline script
└── commands/
    ├── statuslineupdate.sh    # Set manual status
    └── statuslineclear.sh     # Clear manual status
```

### Created During Use

```
.statusline-manual-*           # Manual status files (gitignored)
```

### Should Be Gitignored

Add to your project's `.gitignore`:

```gitignore
# Statusline manual text files
.statusline-manual*
```

## Dependencies

### Required

- **PowerShell 5.1+** (Windows built-in)
- **Claude Code CLI** (official installation)

### Optional

- **ccusage** - For AI model display
  ```powershell
  npm install -g ccusage
  ```

- **CC PowerShell Alias** - For automatic PANE_NAME management
  - See `../powershell/` for installation

## See Also

- [Main README](../README.md) - Project overview and problem statement
- [Installation Guide](../docs/INSTALLATION.md) - Step-by-step setup
- [Examples](../docs/EXAMPLES.md) - Real-world workflows
- [Troubleshooting](../docs/TROUBLESHOOTING.md) - Common issues

## License

MIT License - See [LICENSE](../LICENSE)

## Author

Dennis - https://github.com/pdbdnt/claude-cc-multiinstance-manual-statusline
