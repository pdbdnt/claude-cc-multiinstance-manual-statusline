# Installation Guide

Complete step-by-step guide to installing and configuring the Claude CC Multi-Instance Manual Statusline.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Part 1: PowerShell Functions](#part-1-powershell-functions)
- [Part 2: Claude Code Statusline](#part-2-claude-code-statusline)
- [Part 3: Optional Enhancements](#part-3-optional-enhancements)
- [Verification](#verification)
- [Next Steps](#next-steps)

## Prerequisites

### Required

1. **Windows** with PowerShell 5.1+ (built-in)
   ```powershell
   $PSVersionTable.PSVersion
   # Should show: Major 5, Minor 1 or higher
   ```

2. **Claude Code CLI** installed and in PATH
   ```powershell
   Get-Command claude
   # Should show path to claude.exe or claude.ps1
   ```
   If not installed: [Download Claude Code CLI](https://claude.ai/download)

### Recommended

3. **Git** (for cloning the repository)
   ```powershell
   Get-Command git
   ```
   If not installed: [Download Git for Windows](https://git-scm.com/download/win)

### Optional

4. **ccusage** (for AI model display in statusline)
   ```powershell
   npm install -g ccusage
   ```
   Requires Node.js/npm installed

## Part 1: PowerShell Functions

Install the `sl` and `cc` functions to your PowerShell profile.

### Option A: Automatic Installation (Recommended)

1. **Clone or download this repository:**
   ```powershell
   cd C:\Users\$env:USERNAME\repos
   git clone https://github.com/pdbdnt/claude-cc-multiinstance-manual-statusline.git
   ```

2. **Run the installer:**
   ```powershell
   cd claude-cc-multiinstance-manual-statusline\powershell
   .\install.ps1
   ```

3. **Follow the prompts:**
   - Installer will detect your PowerShell profile
   - Creates backup of existing profile
   - Appends `sl` and `cc` functions
   - Tests installation

4. **Restart PowerShell** (or reload profile):
   ```powershell
   . $PROFILE
   ```

5. **Verify installation:**
   ```powershell
   Get-Command sl
   Get-Command cc
   # Both should show: CommandType: Function
   ```

### Option B: Manual Installation

1. **Locate your PowerShell profile:**
   ```powershell
   echo $PROFILE
   # Example: C:\Users\YourName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
   ```

2. **Create profile if it doesn't exist:**
   ```powershell
   if (!(Test-Path $PROFILE)) {
       New-Item -Path $PROFILE -ItemType File -Force
   }
   ```

3. **Open profile in editor:**
   ```powershell
   notepad $PROFILE
   ```

4. **Copy contents of `powershell/cc-functions.ps1`:**
   - Open `claude-cc-multiinstance-manual-statusline\powershell\cc-functions.ps1`
   - Copy all contents
   - Paste at the end of your profile
   - Save and close

5. **Reload profile:**
   ```powershell
   . $PROFILE
   ```

6. **Test:**
   ```powershell
   sl TestSession
   # Should output: "Pane name set to: TESTSESSION"
   ```

### Troubleshooting Installation

**PowerShell execution policy error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Profile not loading:**
```powershell
# Check for syntax errors
powershell -NoProfile -Command ". $PROFILE"
```

**Functions not available:**
```powershell
# Manually reload
. $PROFILE

# Or restart PowerShell terminal
```

## Part 2: Claude Code Statusline

Install the custom statusline configuration to your Claude Code projects.

### Per-Project Setup

The statusline must be configured **per project** (not global).

1. **Navigate to your project:**
   ```powershell
   cd C:\path\to\your\project
   ```

2. **Copy `.claude` folder:**
   ```powershell
   # From toolkit repo
   cp -r C:\Users\$env:USERNAME\repos\claude-cc-multiinstance-manual-statusline\claude-code\.claude .\.claude

   # Or use full path
   Copy-Item -Path "C:\path\to\claude-cc-multiinstance-manual-statusline\claude-code\.claude" -Destination ".\.claude" -Recurse
   ```

3. **Verify structure:**
   ```powershell
   tree .claude /F
   ```
   Should show:
   ```
   .claude
   ├── settings.json
   ├── statusline-simple.ps1
   └── commands
       ├── statuslineupdate.sh
       └── statuslineclear.sh
   ```

4. **Add to .gitignore** (optional but recommended):
   ```powershell
   # Add to your project's .gitignore
   echo "" >> .gitignore
   echo "# Statusline manual text files" >> .gitignore
   echo ".statusline-manual*" >> .gitignore
   ```

5. **Test statusline:**
   ```powershell
   claude
   ```
   You should see a statusline like:
   ```
   \path\project | Idle
   ```

### Global Template (Optional)

Create a template to copy to new projects:

1. **Create global .claude template:**
   ```powershell
   mkdir C:\Users\$env:USERNAME\.claude-template
   cp -r C:\Users\$env:USERNAME\repos\claude-cc-multiinstance-manual-statusline\claude-code\.claude\* C:\Users\$env:USERNAME\.claude-template\
   ```

2. **Use in new projects:**
   ```powershell
   cd C:\path\to\new\project
   cp -r C:\Users\$env:USERNAME\.claude-template .\.claude
   ```

## Part 3: Optional Enhancements

### Install ccusage (AI Model Display)

Shows current AI model in statusline.

1. **Install via npm:**
   ```powershell
   npm install -g ccusage
   ```

2. **Verify installation:**
   ```powershell
   Get-Command ccusage
   ccusage --version
   ```

3. **Test with statusline:**
   ```powershell
   cd C:\path\to\project
   claude
   ```
   Statusline should now show:
   ```
   \path\project | Sonnet 4.5 | Idle
   ```

### Custom Execution Policy

If you frequently encounter execution policy issues:

```powershell
# Allow scripts signed by trusted publishers
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Or allow all local scripts (less secure)
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser
```

## Verification

### Test PowerShell Functions

```powershell
# Test sl function
sl TestIdentifier
# Expected: "Pane name set to: TESTIDENTIFIER"

# Verify PANE_NAME env var
echo $env:PANE_NAME
# Expected: TESTIDENTIFIER

# Test cc function (launches Claude Code)
cc --help
# Should show Claude Code help
```

### Test Statusline

1. **Launch Claude Code:**
   ```powershell
   cd C:\path\to\project
   claude
   ```

2. **Check statusline appears:**
   - Should show project path
   - Should show "Idle" (or current task)

3. **Test manual status:**
   ```
   /statuslineupdate Testing installation
   ```
   Statusline should update to:
   ```
   \path\project | [M] Testing installation | Idle
   ```

4. **Clear manual status:**
   ```
   /statuslineclear
   ```
   `[M] ...` section should disappear

### Test Full Workflow

```powershell
# Set identifier and launch
sl InstallTest
cc

# Inside Claude Code
/statuslineupdate Verifying toolkit works

# Expected statusline:
# \path\project | [M] Verifying toolkit works | <model> | Idle
```

## Common Installation Issues

### Issue: "Cannot be loaded because running scripts is disabled"

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: "sl is not recognized"

**Cause:** Profile not loaded or functions not installed

**Solution:**
```powershell
# Reload profile
. $PROFILE

# Or verify installation
Get-Content $PROFILE | Select-String "function sl"
```

### Issue: Statusline shows "\unknown"

**Cause:** PowerShell script can't parse JSON

**Solution:**
1. Check `settings.json` syntax
2. Verify PowerShell version: `$PSVersionTable.PSVersion`
3. Test script manually:
   ```powershell
   echo '{"workspace":{"current_dir":"C:\\test"}}' | powershell -NoProfile -File .claude\statusline-simple.ps1
   ```

### Issue: Manual status not showing

**Cause:** PANE_NAME not set or file not created

**Solution:**
```powershell
# Check PANE_NAME
echo $env:PANE_NAME

# If not set, use cc command or set manually
sl MyPane
cc

# Then try /statuslineupdate again
```

### Issue: Model not showing in statusline

**Expected:** This is optional. Install ccusage if desired.

**Solution:**
```powershell
npm install -g ccusage
# Then restart Claude Code
```

## Uninstallation

### Remove PowerShell Functions

```powershell
cd C:\path\to\claude-cc-multiinstance-manual-statusline\powershell
.\uninstall.ps1
```

Or manually:
1. Open `$PROFILE` in editor
2. Remove the section between:
   ```powershell
   # ==== Claude Code Multi-Instance Toolkit ====
   # ... (functions)
   # ==== End of Claude Code Multi-Instance Toolkit ====
   ```
3. Save and reload: `. $PROFILE`

### Remove Statusline (Per Project)

```powershell
cd C:\path\to\project
rm -r .\.claude
rm .statusline-manual*
```

## Next Steps

1. **Read [EXAMPLES.md](EXAMPLES.md)** for real-world workflows
2. **Read [STATUSLINE.md](../claude-code/STATUSLINE.md)** for statusline reference
3. **Read [TROUBLESHOOTING.md](TROUBLESHOOTING.md)** for common issues

## Getting Help

- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [GitHub Issues](https://github.com/pdbdnt/claude-cc-multiinstance-manual-statusline/issues)
- [Main README](../README.md)

## Updates

To update to the latest version:

```powershell
cd C:\Users\$env:USERNAME\repos\claude-cc-multiinstance-manual-statusline
git pull origin main

# Re-run installer
cd powershell
.\install.ps1

# Update statusline in projects
cd C:\path\to\project
rm -r .\.claude
cp -r C:\Users\$env:USERNAME\repos\claude-cc-multiinstance-manual-statusline\claude-code\.claude .\.claude
```

---

[← Back to README](../README.md)
