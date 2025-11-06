# Troubleshooting Guide

Common issues and solutions for the Claude Code Multi-Instance Toolkit.

## PowerShell Functions Issues

### `sl` or `cc` command not found

**Symptoms:**
```
sl : The term 'sl' is not recognized as the name of a cmdlet, function, script file...
```

**Causes & Solutions:**

1. **Profile not loaded**
   ```powershell
   # Reload profile
   . $PROFILE

   # Or restart PowerShell
   ```

2. **Functions not installed**
   ```powershell
   # Check if functions exist in profile
   Get-Content $PROFILE | Select-String "function sl"

   # If not found, re-run installer
   cd C:\path\to\claude-cc-multiinstance-manual-statusline\powershell
   .\install.ps1
   ```

3. **Using wrong PowerShell**
   - Ensure you're in PowerShell, not CMD
   - Check: `$PSVersionTable` should show PowerShell version

### Execution policy error

**Symptoms:**
```
.\install.ps1 : File cannot be loaded because running scripts is disabled on this system.
```

**Solution:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Explanation:** Windows blocks script execution by default for security.

### `cc` launches but Claude Code not found

**Symptoms:**
```
claude : The term 'claude' is not recognized...
```

**Solution:**
1. Install Claude Code CLI: https://claude.ai/download
2. Verify installation:
   ```powershell
   Get-Command claude
   ```
3. Add to PATH if needed

### PANE_NAME not persisting

**Symptoms:**
- Set `sl MyPane` but `$env:PANE_NAME` is empty
- Manual status files not created with PANE_NAME

**Solution:**
- `PANE_NAME` only persists for current PowerShell session
- Each new terminal window needs `sl` or `cc` command
- To persist across sessions, add to `$PROFILE`:
  ```powershell
  $env:PANE_NAME = "MyDefaultPane"
  ```

## Statusline Issues

### Statusline not appearing

**Symptoms:**
- No statusline visible in Claude Code CLI

**Diagnosis:**
```powershell
# 1. Check settings.json exists
Test-Path .claude\settings.json

# 2. Check statusline script exists
Test-Path .claude\statusline-simple.ps1

# 3. Test script manually
echo '{"workspace":{"current_dir":"C:\\test"}}' | powershell -NoProfile -File .claude\statusline-simple.ps1
# Should output: \test | Idle (or similar)
```

**Solutions:**

1. **Missing .claude folder**
   ```powershell
   # Copy from toolkit
   cp -r C:\path\to\claude-cc-multiinstance-manual-statusline\claude-code\.claude .\.claude
   ```

2. **Invalid settings.json**
   ```powershell
   # Check JSON syntax
   Get-Content .claude\settings.json | ConvertFrom-Json
   ```

3. **PowerShell version too old**
   ```powershell
   $PSVersionTable.PSVersion
   # Should be 5.1+ (Windows built-in)
   ```

### Statusline shows "\unknown"

**Symptoms:**
```
\unknown | Idle
```

**Cause:** Script can't parse workspace directory from JSON

**Solutions:**

1. **Check PowerShell version**
   ```powershell
   $PSVersionTable.PSVersion
   # Needs 5.1+
   ```

2. **Test JSON parsing**
   ```powershell
   echo '{"workspace":{"current_dir":"C:\\apps\\test"}}' | ConvertFrom-Json
   ```

3. **Verify Claude Code is sending JSON**
   - This should be automatic
   - If broken, file a bug with Claude Code team

### Statusline shows "\error"

**Symptoms:**
```
\error
```

**Cause:** Unhandled exception in statusline script

**Diagnosis:**
```powershell
# Run script with error details
echo '{"workspace":{"current_dir":"C:\\apps\\test"}}' | powershell -File .claude\statusline-simple.ps1 2>&1
```

**Common causes:**
- Syntax error in script
- Permission error reading transcript
- Corrupt transcript file

### Manual status not showing

**Symptoms:**
- Run `/statuslineupdate My text`
- Statusline doesn't show `[M] My text`

**Diagnosis:**

1. **Check PANE_NAME**
   ```powershell
   echo $env:PANE_NAME
   ```
   - If empty, use `sl MyPane` or `cc` first

2. **Check manual file created**
   ```powershell
   # With PANE_NAME
   ls .statusline-manual-*

   # Without PANE_NAME
   ls .statusline-manual
   ```

3. **Check file contents**
   ```powershell
   cat .statusline-manual-$env:PANE_NAME
   ```

**Solutions:**

1. **Set PANE_NAME first**
   ```powershell
   sl MySession
   cc
   /statuslineupdate My text
   ```

2. **Verify statusline script reads PANE_NAME**
   ```powershell
   # Should contain this logic
   Select-String -Path .claude\statusline-simple.ps1 -Pattern "PANE_NAME"
   ```

3. **Check file permissions**
   ```powershell
   # Ensure you can write to project directory
   echo "test" > .test-write
   rm .test-write
   ```

### AI model not showing

**Symptoms:**
- Statusline missing model section (e.g., "Sonnet 4.5")

**Expected Behavior:** This is optional and requires `ccusage` installation.

**To enable:**
```powershell
# Install ccusage
npm install -g ccusage

# Verify
Get-Command ccusage
ccusage --version

# Restart Claude Code
```

**If still not showing:**
- `ccusage` might not be in PATH
- Restart terminal after installing
- Check: `echo $inputData | ccusage statusline`

### Task tracking shows "Idle" when working

**Symptoms:**
- Actively using TodoWrite or Task tools
- Statusline still shows "Idle"

**Causes:**

1. **Transcript not written yet**
   - Wait a few seconds for transcript to update
   - Statusline refreshes periodically

2. **TodoWrite format changed**
   - Script parses specific JSON structure
   - If Claude Code updates format, script may break

3. **Transcript path incorrect**
   - Script reads from `json.transcript_path`
   - Verify path exists

**Diagnosis:**
```powershell
# Check transcript file
ls C:\Users\$env:USERNAME\.claude\transcripts\
```

## Integration Issues

### CC alias and statusline not working together

**Symptoms:**
- `cc` command works
- Statusline works
- But manual status not pane-specific

**Cause:** PANE_NAME not being read by statusline

**Solution:**

1. **Verify PANE_NAME is set**
   ```powershell
   sl TestPane
   echo $env:PANE_NAME
   # Should show: TESTPANE
   ```

2. **Check statusline reads PANE_NAME**
   ```powershell
   # Test manually
   $env:PANE_NAME = "TESTPANE"
   echo '{"workspace":{"current_dir":"C:\\test"}}' | powershell -File .claude\statusline-simple.ps1
   ```

3. **Verify file created with PANE_NAME**
   ```powershell
   /statuslineupdate Test text
   ls .statusline-manual-*
   # Should show .statusline-manual-TESTPANE
   ```

### Multiple terminals sharing same manual status

**Symptoms:**
- Update status in Terminal 1
- Terminal 2's statusline also changes

**Cause:** Both terminals using same PANE_NAME or no PANE_NAME

**Solution:**
- Use `cc` command (auto-generates unique PANE_NAME)
- Or set unique PANE_NAME manually:
  ```powershell
  # Terminal 1
  sl Terminal1

  # Terminal 2
  sl Terminal2
  ```

## Performance Issues

### Statusline slow to update

**Expected:** Statusline refreshes every few seconds, not instant.

**If very slow (>10 seconds):**

1. **Large transcript file**
   - Parsing huge transcripts is slow
   - Archive old transcripts

2. **Slow disk I/O**
   - Transcript on network drive
   - Move to local SSD

3. **ccusage slow**
   - Disable ccusage by removing it:
     ```powershell
     npm uninstall -g ccusage
     ```

### PowerShell profile slow to load

**Cause:** Too many functions or commands in profile

**Solution:**
- CC functions are lightweight (~200 lines)
- Check for other slow profile code
- Profile loading time: `Measure-Command { . $PROFILE }`

## Git/Version Control Issues

### `.statusline-manual-*` files in git

**Symptoms:**
- Manual status files appear in `git status`

**Solution:**
```powershell
# Add to .gitignore
echo "" >> .gitignore
echo "# Statusline manual text files" >> .gitignore
echo ".statusline-manual*" >> .gitignore

# Remove from git if already committed
git rm --cached .statusline-manual-*
git commit -m "Remove statusline manual files from git"
```

### `.claude` folder in git

**Decision:** Should you commit .claude?

**Recommendation:** Yes (project-specific configuration)

```gitignore
# Commit .claude folder
# But ignore manual status files
.statusline-manual*
```

**Alternative:** Gitignore .claude and document setup in README

## Windows-Specific Issues

### Backslash vs forward slash in paths

**Issue:** PowerShell uses `\`, bash uses `/`

**Solution:** Script normalizes paths:
```powershell
$normalizedPath = $path -replace '/', '\'
```

No action needed from users.

### CMD vs PowerShell

**Issue:** Trying to use CC functions in CMD

**Solution:**
- CC toolkit requires PowerShell
- Open PowerShell terminal instead of CMD
- Windows Terminal defaults to PowerShell

### Line ending issues (CRLF vs LF)

**Issue:** Bash scripts (.sh) with CRLF line endings fail

**Solution:**
```powershell
# Convert to LF
dos2unix .claude\commands\*.sh

# Or in git
git config core.autocrlf input
```

## Getting More Help

### Enable Debug Output

```powershell
# Test statusline with verbose output
echo '{"workspace":{"current_dir":"C:\\test"},"transcript_path":"C:\\Users\\user\\.claude\\transcripts\\test.jsonl"}' | powershell -File .claude\statusline-simple.ps1 2>&1 | Out-File debug.txt

# Check debug.txt for errors
cat debug.txt
```

### Check Versions

```powershell
# PowerShell version
$PSVersionTable.PSVersion

# Claude Code version
claude --version

# ccusage version (if installed)
ccusage --version

# Node.js version (if using ccusage)
node --version
```

### File a Bug Report

Include:
1. **Error message** (copy/paste full text)
2. **Steps to reproduce**
3. **Your environment:**
   ```powershell
   $PSVersionTable.PSVersion
   claude --version
   ```
4. **Relevant config files:**
   - `.claude\settings.json`
   - Statusline script (first 50 lines)

[Open an issue](https://github.com/pdbdnt/claude-cc-multiinstance-manual-statusline/issues)

## Known Limitations

### Statusline updates every N seconds

- Not instant (by design - prevents performance issues)
- Typical refresh: 2-5 seconds
- Can't be made real-time due to Claude Code architecture

### PowerShell-only (Windows)

- Bash/zsh versions possible but not included
- Contributions welcome for cross-platform support

### Per-project statusline setup

- Must copy `.claude` folder to each project
- No global statusline config (by Claude Code design)

### PANE_NAME not visible in statusline by default

- Only shows via manual status: `[M] YourPaneName`
- Or update statusline script to always show PANE_NAME

## See Also

- [Installation Guide](INSTALLATION.md) - Setup instructions
- [Examples](EXAMPLES.md) - Usage workflows
- [Statusline Documentation](../claude-code/STATUSLINE.md) - Statusline reference
- [Main README](../README.md) - Project overview

---

[← Back to README](../README.md)
