<#
.SYNOPSIS
    Repairs the `memories forget` no-op bug in @ninkch/opencode-mem (v1.1.0).

.DESCRIPTION
    @ninkch/opencode-mem v1.1.0 ships a duplicate CLI dispatch branch in
    dist/cli.js:

        else if (subCommand === "forget") {
        }
        else if (subCommand === "forget") {
            const id = args[1];
            ... store.deleteMemory(id); ...

    JavaScript evaluates else-if branches in order, so the EMPTY branch always
    wins: `opencode-mem memories forget <id>` exits 0, prints nothing, and
    deletes nothing. The underlying store.deleteMemory() is intact.

    This script removes ONLY the empty duplicate branch(es) from the globally
    installed package, leaving the real handler untouched. It is idempotent:
    re-running it after the repair (or against a future upstream release that
    fixes the bug) changes nothing and exits 0.

    WHEN TO RE-RUN: after every `npm install -g @ninkch/opencode-mem`,
    upgrade, or reinstall, then verify with:
        opencode-mem memories list

    SCOPE: touches a single file outside this repository
    (<npm-global>/@ninkch/opencode-mem/dist/cli.js). It never touches the
    memory database, OpenCode configuration, agent permissions, or prompts.

.EXAMPLE
    pwsh ./scripts/Repair-OpencodeMemForget.ps1
#>
[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PackageName = '@ninkch/opencode-mem'
$RelativeCli  = '@ninkch/opencode-mem/dist/cli.js'

# An `else if (subCommand === "forget") {` line immediately followed by a
# closing-brace-only line: the empty shadowing branch. CRLF- and LF-safe.
$EmptyBranchPattern = '(?m)^[ \t]*else if \(subCommand === "forget"\) \{\r?\n[ \t]*\}\r?\n'
# A remaining forget handler that actually deletes.
$WorkingHandlerPattern = '(?s)else if \(subCommand === "forget"\) \{.*?store\.deleteMemory'

function Get-GlobalCliPath {
    $npmRoot = (& npm root -g 2>$null | Select-Object -First 1).Trim()
    if (-not $npmRoot) {
        throw "Could not determine the global npm root (`npm root -g` failed). Is npm on PATH?"
    }
    $cliPath = Join-Path -Path $npmRoot -ChildPath ($RelativeCli -replace '/', [IO.Path]::DirectorySeparatorChar)
    if (-not (Test-Path -LiteralPath $cliPath -PathType Leaf)) {
        throw "Package file not found: $cliPath. Is $PackageName installed globally (`npm install -g $PackageName`)?"
    }
    return $cliPath
}

$cliPath = Get-GlobalCliPath
Write-Host "Target: $cliPath"

$utf8NoBom = [Text.UTF8Encoding]::new($false)
$original = [IO.File]::ReadAllText($cliPath, $utf8NoBom)

$emptyMatches = [regex]::Matches($original, $EmptyBranchPattern)
if ($emptyMatches.Count -eq 0) {
    if ($original -match $WorkingHandlerPattern) {
        Write-Host "OK: no empty duplicate 'forget' branch found; a working handler is present. Nothing to do."
        exit 0
    }
    Write-Error "Refusing to modify ${cliPath}: no empty duplicate branch AND no recognizable working 'forget' handler. Layout differs from the expected v1.1.0 defect; manual review required."
    exit 2
}

$fixed = [regex]::Replace($original, $EmptyBranchPattern, '')

# Post-repair validation BEFORE writing: no empty branch may remain, and a
# working handler (one that calls store.deleteMemory) must still exist.
if ([regex]::Matches($fixed, $EmptyBranchPattern).Count -ne 0) {
    Write-Error "Refusing to write ${cliPath}: empty 'forget' branch still present after repair."
    exit 2
}
if ($fixed -notmatch $WorkingHandlerPattern) {
    Write-Error "Refusing to write ${cliPath}: no working 'forget' handler (store.deleteMemory) remains after repair."
    exit 2
}

[IO.File]::WriteAllText($cliPath, $fixed, $utf8NoBom)
Write-Host "Repaired: removed $($emptyMatches.Count) empty duplicate 'forget' branch(es); working handler preserved."
