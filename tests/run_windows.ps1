# tests/run_windows.ps1 — Windows-native verification of the starter pack structure
# Validates file structure, YAML frontmatter, JSON validity, and README consistency.

$ErrorActionPreference = "Stop"

$ROOT = Split-Path -Parent $PSScriptRoot
if (-not $ROOT) { $ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path }
Set-Location $ROOT

$PASS = 0
$FAIL = 0

function Ok($msg) { Write-Host "  OK   $msg" -ForegroundColor Green; $script:PASS++ }
function Bad($msg, $detail) { 
    Write-Host "  FAIL $msg" -ForegroundColor Red
    if ($detail) { Write-Host "       $detail" -ForegroundColor Red }
    $script:FAIL++ 
}

# == 1. SKILL.md frontmatter ==
Write-Host "== 1. SKILL.md frontmatter ==" -ForegroundColor Cyan
$skills = @("commit-helper", "code-reviewer", "readme-writer", "bug-report")
foreach ($skill in $skills) {
    $skillFile = Join-Path $ROOT "skills\$skill\SKILL.md"
    if (-not (Test-Path $skillFile)) {
        Bad "$skill" "SKILL.md not found at $skillFile"
        continue
    }
    $content = Get-Content $skillFile -Raw
    # Check starts with ---
    if (-not $content.StartsWith("---")) {
        Bad "$skill" "SKILL.md must start with '---'"
        continue
    }
    # Extract frontmatter
    $fmEnd = $content.IndexOf("`n---`n", 4)
    if ($fmEnd -lt 0) { $fmEnd = $content.IndexOf("`r`n---`r`n", 4) }
    if ($fmEnd -lt 0) {
        Bad "$skill" "Could not find closing '---' for frontmatter"
        continue
    }
    $fm = $content.Substring(4, $fmEnd - 4)
    
    # Check name field exists and matches directory
    if ($fm -match 'name:\s*(.+)') {
        $fmName = $Matches[1].Trim()
        if ($fmName -eq $skill) {
            Ok "$skill`: valid frontmatter, name matches directory"
        } else {
            Bad "$skill" "name '$fmName' does not match directory '$skill'"
        }
    } else {
        Bad "$skill" "missing 'name' in frontmatter"
    }
    
    # Check description field exists
    if ($fm -notmatch 'description:') {
        Bad "$skill" "missing 'description' in frontmatter"
    }
}

# == 2. JSON files ==
Write-Host "`n== 2. JSON files ==" -ForegroundColor Cyan
$jsonFile = Join-Path $ROOT ".claude\settings.json.example"
if (Test-Path $jsonFile) {
    try {
        Get-Content $jsonFile -Raw | ConvertFrom-Json | Out-Null
        Ok "$jsonFile`: valid JSON"
    } catch {
        Bad "$jsonFile" $_.Exception.Message
    }
} else {
    Bad ".claude/settings.json.example" "file not found"
}

# == 3. protect-files.sh content check ==
Write-Host "`n== 3. protect-files.sh content check ==" -ForegroundColor Cyan
$hookFile = Join-Path $ROOT ".claude\hooks\protect-files.sh"
if (Test-Path $hookFile) {
    $hookContent = Get-Content $hookFile -Raw
    $patterns = @(".env", "package-lock.json", ".git/", "id_rsa", ".pem")
    $allFound = $true
    foreach ($p in $patterns) {
        if ($hookContent -notmatch [regex]::Escape($p)) {
            Bad "protect-files.sh" "missing pattern: $p"
            $allFound = $false
        }
    }
    if ($allFound) {
        Ok "protect-files.sh: contains all expected protection patterns"
    }
} else {
    Bad "protect-files.sh" "file not found"
}

# == 4. setup.sh content check ==
Write-Host "`n== 4. setup.sh content check ==" -ForegroundColor Cyan
$setupFile = Join-Path $ROOT "setup.sh"
if (Test-Path $setupFile) {
    $setupContent = Get-Content $setupFile -Raw
    $flags = @("--project", "--dry-run", "--force", "--help")
    $allFound = $true
    foreach ($f in $flags) {
        if ($setupContent -notmatch [regex]::Escape($f)) {
            Bad "setup.sh" "missing flag: $f"
            $allFound = $false
        }
    }
    if ($allFound) {
        Ok "setup.sh: supports all expected flags (--project, --dry-run, --force, --help)"
    }
} else {
    Bad "setup.sh" "file not found"
}

# == 5. README <-> actual files consistency ==
Write-Host "`n== 5. README <-> actual files consistency ==" -ForegroundColor Cyan
$readmeContent = Get-Content (Join-Path $ROOT "README.md") -Raw
foreach ($skill in $skills) {
    if ($readmeContent -match $skill) {
        Ok "README mentions skill: $skill"
    } else {
        Bad "README mentions skill: $skill" "not found in README.md"
    }
    $skillPath = Join-Path $ROOT "skills\$skill\SKILL.md"
    if (Test-Path $skillPath) {
        Ok "skill dir exists: $skill"
    } else {
        Bad "skill dir exists: $skill" "missing skills/$skill/SKILL.md"
    }
}

# == 6. Required files exist ==
Write-Host "`n== 6. Required files exist ==" -ForegroundColor Cyan
$requiredFiles = @(
    "README.md",
    "CLAUDE.md.template",
    "setup.sh",
    "LICENSE",
    ".claude\settings.json.example",
    ".claude\hooks\protect-files.sh",
    ".claude\hooks\README.md",
    "tests\run.sh",
    "tests\README.md",
    "docs\getting-started.md",
    "docs\writing-skills.md",
    "examples\walkthrough.md"
)
foreach ($f in $requiredFiles) {
    $fullPath = Join-Path $ROOT $f
    if (Test-Path $fullPath) {
        Ok "exists: $f"
    } else {
        Bad "exists: $f" "file not found"
    }
}

# == 7. Directory structure matches README ==
Write-Host "`n== 7. Directory structure matches README ==" -ForegroundColor Cyan
$requiredDirs = @(
    "skills",
    "skills\commit-helper",
    "skills\code-reviewer",
    "skills\readme-writer",
    "skills\bug-report",
    ".claude",
    ".claude\hooks",
    "docs",
    "examples",
    "tests"
)
foreach ($d in $requiredDirs) {
    $fullPath = Join-Path $ROOT $d
    if (Test-Path $fullPath -PathType Container) {
        Ok "directory: $d"
    } else {
        Bad "directory: $d" "not found"
    }
}

# == Summary ==
Write-Host ""
Write-Host "================================" -ForegroundColor Yellow
Write-Host "  Passed: $PASS   Failed: $FAIL" -ForegroundColor $(if ($FAIL -eq 0) { "Green" } else { "Red" })
Write-Host "================================" -ForegroundColor Yellow

exit $FAIL
