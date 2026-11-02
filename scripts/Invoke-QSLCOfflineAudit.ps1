[CmdletBinding()]
param(
    [string]$RepoPath = (Join-Path $HOME "QSLC"),
    [switch]$RunTests
)
$ErrorActionPreference = "Continue"
$report = [System.Collections.Generic.List[string]]::new()
function Add-Result([string]$Name, [string]$Value) {
    $line = "{0,-28} {1}" -f $Name, $Value
    $report.Add($line)
    Write-Host $line
}
Write-Host "`nQSLC OFFLINE / LOCAL READ-ONLY AUDIT" -ForegroundColor Cyan
Write-Host "No installs, upgrades, deployments, file moves, or deletions will be performed.`n"
Add-Result "Audit timestamp" (Get-Date -Format "yyyy-MM-dd HH:mm:ss K")
Add-Result "Running PowerShell" $PSVersionTable.PSVersion.ToString()
Add-Result "Operating system" ([System.Runtime.InteropServices.RuntimeInformation]::OSDescription)
$shells = @()
foreach ($name in @("pwsh", "powershell")) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) {
        $versionText = & $cmd.Source -NoLogo -NoProfile -Command '$PSVersionTable.PSVersion.ToString()' 2>$null
        try { $version = [version]("$versionText".Trim()) } catch { $version = [version]"0.0" }
        $shells += [pscustomobject]@{ Name=$name; Version=$version; Path=$cmd.Source }
    }
}
if ($shells.Count -gt 0) {
    $latestShell = $shells | Sort-Object Version -Descending | Select-Object -First 1
    Add-Result "Newest installed shell" "$($latestShell.Name) $($latestShell.Version) [$($latestShell.Path)]"
} else { Add-Result "Newest installed shell" "No PowerShell executable found" }
foreach ($name in @("python", "py", "git", "conda", "code", "node", "npm", "wrangler")) {
    $cmd = Get-Command $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd) {
        $version = switch ($name) {
            "python" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "py" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "git" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "conda" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "code" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "node" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "npm" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
            "wrangler" { & $cmd.Source --version 2>&1 | Select-Object -First 1 }
        }
        Add-Result $name "$version [$($cmd.Source)]"
    } else { Add-Result $name "NOT FOUND" }
}
if (Test-Path -LiteralPath $RepoPath) {
    Set-Location -LiteralPath $RepoPath
    Add-Result "QSLC workspace" (Get-Location).Path
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        $branch = & git branch --show-current 2>$null
        $head = & git log -1 --format="%h %cI %s" 2>$null
        $status = & git status --short 2>$null
        Add-Result "Git branch" $(if ($branch) {$branch} else {"UNAVAILABLE"})
        Add-Result "Latest local commit" $(if ($head) {$head} else {"UNAVAILABLE"})
        Add-Result "Working tree" $(if ($LASTEXITCODE -eq 0 -and -not $status) {"CLEAN"} elseif ($status) {"CHANGES PRESENT"} else {"UNKNOWN"})
        if ($status) { $status | ForEach-Object { Add-Result "Git change" $_ } }
    } else { Add-Result "Git repository" "Git not installed or not on PATH" }
    $pythonCmd = Get-Command python -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $pythonCmd) { $pythonCmd = Get-Command py -ErrorAction SilentlyContinue | Select-Object -First 1 }
    if ($pythonCmd) {
        $env:PYTHONDONTWRITEBYTECODE = "1"
        $probe = @'
import importlib.util, pathlib, sys
print("Python:", sys.version.split()[0])
for name in ("streamlit", "pandas", "pytest"):
    print(f"{name}:", "AVAILABLE" if importlib.util.find_spec(name) else "MISSING")
for name in ("qslc_dashboard_app.py", "qsls_dashboard_app.py", "streamlit_app.py"):
    p = pathlib.Path(name)
    if p.is_file():
        try:
            compile(p.read_text(encoding="utf-8"), str(p), "exec")
            print(f"syntax {name}: PASS")
        except Exception as exc:
            print(f"syntax {name}: FAIL - {exc}")
'@
        $probe | & $pythonCmd.Source -
        Add-Result "Python local probe" $(if ($LASTEXITCODE -eq 0) {"COMPLETED"} else {"FAILED"})
        if ($RunTests) {
            & $pythonCmd.Source -m pytest -q -p no:cacheprovider
            Add-Result "Local pytest" $(if ($LASTEXITCODE -eq 0) {"PASS"} else {"FAIL / NOT RUN"})
        } else { Add-Result "Local pytest" "SKIPPED (rerun with -RunTests)" }
    } else { Add-Result "Python local probe" "SKIPPED - Python not found" }
    foreach ($path in @("SSOT.md","qslc_dashboard_app.py","qsls_dashboard_app.py","streamlit_app.py","environment.yml","requirements.txt","tests/test_apps.py",".devcontainer/devcontainer.json")) {
        if (Test-Path -LiteralPath $path) {
            $item = Get-Item -LiteralPath $path
            Add-Result "File $path" ("present; modified " + $item.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss"))
        } else { Add-Result "File $path" "MISSING" }
    }
} else {
    Add-Result "QSLC workspace" "NOT FOUND: $RepoPath"
    Add-Result "Local repository checks" "SKIPPED"
}
$reportPath = Join-Path $env:TEMP ("QSLC-Offline-Audit-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".txt")
$report | Set-Content -LiteralPath $reportPath -Encoding UTF8
Write-Host "`nAudit summary saved to: $reportPath" -ForegroundColor Green
Write-Host "Review all results before changing launch targets or archiving files."
