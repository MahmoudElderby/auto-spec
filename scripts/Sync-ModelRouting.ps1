#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Resolve phase->model map and materialize phase agent binders for Cursor and Codex.
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = "",
    [string]$ConfigPath = "",
    [string]$ExtensionId = "auto-spec",
    [switch]$DryRun,
    [switch]$Json
)

$ErrorActionPreference = "Stop"

function Find-ProjectRoot {
    param([string]$Start)
    $dir = (Resolve-Path $Start).Path
    while ($true) {
        if (Test-Path (Join-Path $dir ".specify")) { return $dir }
        $parent = Split-Path $dir -Parent
        if (-not $parent -or $parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

function Get-YamlScalarMap {
    param([string]$Text)
    $result = @{
        schema_version = $null
        execution      = "task"
        phases         = [ordered]@{}
        aliases        = [ordered]@{}
        pipeline       = [ordered]@{}
    }
    $section = $null
    foreach ($raw in ($Text -split "`n")) {
        $line = $raw.TrimEnd("`r")
        if ($line -match '^\s*#' -or $line.Trim() -eq "") { continue }
        if ($line -match '^(schema_version)\s*:\s*(.+)\s*$') {
            $result.schema_version = $matches[2].Trim().Trim('"').Trim("'")
            $section = $null
            continue
        }
        if ($line -match '^(execution)\s*:\s*(.+)\s*$') {
            $result.execution = $matches[2].Trim().Trim('"').Trim("'")
            $section = $null
            continue
        }
        if ($line -match '^(phases)\s*:\s*$') { $section = "phases"; continue }
        if ($line -match '^(aliases)\s*:\s*$') { $section = "aliases"; continue }
        if ($line -match '^(pipeline)\s*:\s*$') { $section = "pipeline"; continue }
        if ($section -and $line -match '^\s+("?)([^":]+)\1\s*:\s*(.+)\s*$') {
            $key = $matches[2].Trim()
            $val = $matches[3].Trim().Trim('"').Trim("'")
            if ($section -eq "phases") { $result.phases[$key] = $val }
            elseif ($section -eq "aliases") { $result.aliases[$key] = $val }
            elseif ($section -eq "pipeline") { $result.pipeline[$key] = $val }
        }
    }
    return $result
}

function Resolve-Model {
    param([string]$Raw, $Aliases, [int]$Depth = 0)
    if ([string]::IsNullOrWhiteSpace($Raw)) { return "inherit" }
    $value = $Raw.Trim()
    if ($Depth -gt 8) { return $value }
    $key = $value.ToLowerInvariant()
    foreach ($ak in @($Aliases.Keys)) {
        if ($ak.ToString().ToLowerInvariant() -eq $key) {
            $next = [string]$Aliases[$ak]
            if ($next -eq $value) { return $value }
            return (Resolve-Model -Raw $next -Aliases $Aliases -Depth ($Depth + 1))
        }
    }
    return $value
}

function Get-AgentTargetLayouts {
    return @(
        @{ name = "cursor-agent"; skillsDir = ".cursor/skills"; agentsDir = ".cursor/agents"; invoke = "/speckit-" }
        @{ name = "codex"; skillsDir = ".agents/skills"; agentsDir = ".agents/agents"; invoke = "`$speckit-" }
    )
}

function New-PhaseAgentMarkdown {
    param(
        [string]$Phase,
        [string]$Model,
        [string]$AgentName,
        [string]$SkillName,
        [string]$Description,
        [string]$SkillsDir,
        [string]$InvokePrefix
    )
    $sb = New-Object System.Text.StringBuilder
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("name: $AgentName")
    [void]$sb.AppendLine("description: >-")
    [void]$sb.AppendLine("  Spec Kit phase agent ($SkillName). Auto Spec / user requests $Phase phase.")
    [void]$sb.AppendLine("  $Description")
    [void]$sb.AppendLine("model: $Model")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("You are the **$Phase** phase worker for Spec Kit SDD.")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Model: ``$Model``")
    [void]$sb.AppendLine("Skill: ``$SkillsDir/$SkillName/SKILL.md`` (invoke: ${InvokePrefix}${Phase})")
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("Do only this phase. Return paths changed, summary, blockers.")
    [void]$sb.AppendLine('Parent input is $ARGUMENTS for the skill.')
    return $sb.ToString()
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptDir

if (-not $ProjectRoot) {
    $ProjectRoot = Find-ProjectRoot -Start (Get-Location).Path
    if (-not $ProjectRoot) { $ProjectRoot = Find-ProjectRoot -Start $scriptDir }
}
if (-not $ProjectRoot) {
    throw "Could not locate Spec Kit project root (no .specify/)."
}

$extDir = Join-Path $ProjectRoot ".specify\extensions\$ExtensionId"
if (-not $ConfigPath) {
    foreach ($candidate in @(
            (Join-Path $extDir "models.yml"),
            (Join-Path $repoRoot "models.yml"),
            (Join-Path $extDir "models.template.yml"),
            (Join-Path $repoRoot "models.template.yml")
        )) {
        if (Test-Path $candidate) { $ConfigPath = $candidate; break }
    }
}
if (-not $ConfigPath -or -not (Test-Path $ConfigPath)) {
    throw "models.yml not found."
}

$map = Get-YamlScalarMap -Text (Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8)
$aliases = @{}
foreach ($k in @($map.aliases.Keys)) { $aliases[$k] = $map.aliases[$k] }

$defaultPhases = @(
    "constitution", "specify", "clarify", "plan", "checklist", "tasks",
    "analyze", "implement", "converge", "taskstoissues"
)

$resolvedList = @()
foreach ($phase in $defaultPhases) {
    $raw = if ($map.phases.Contains($phase)) { [string]$map.phases[$phase] } else { "inherit" }
    $resolvedList += [pscustomobject]@{
        phase      = $phase
        configured = $raw
        model      = (Resolve-Model -Raw $raw -Aliases $aliases)
        skill      = "speckit-$phase"
        agent      = "speckit-$phase"
    }
}

$outJson = Join-Path $extDir "models.resolved.json"
if (-not (Test-Path $extDir)) { New-Item -ItemType Directory -Force -Path $extDir | Out-Null }

$payload = [ordered]@{
    schema_version = $map.schema_version
    execution      = $map.execution
    extension_id   = $ExtensionId
    config_path    = $ConfigPath
    pipeline       = $map.pipeline
    generated_at   = (Get-Date).ToString("o")
    phases         = $resolvedList
}

if ($Json) { $payload | ConvertTo-Json -Depth 6 }

if ($DryRun) {
    Write-Host "Dry run - agent binders for Cursor + Codex"
    foreach ($row in $resolvedList) {
        Write-Host ("  {0,-14} {1,-28} -> {2}" -f $row.phase, $row.configured, $row.model)
    }
    exit 0
}

$skillBlurb = @{
    constitution  = "Create or update project constitution."
    specify       = "Feature specification under specs/."
    clarify       = "Resolve ambiguous requirements."
    plan          = "Technical implementation plan."
    checklist     = "Requirements-quality checklist."
    tasks         = "Actionable tasks.md."
    analyze       = "Cross-artifact consistency report."
    implement     = "Execute tasks."
    converge      = "Gap analysis; append tasks until converged."
    taskstoissues = "Convert tasks to GitHub issues."
}

$layouts = Get-AgentTargetLayouts
foreach ($layout in $layouts) {
    $agentsDir = Join-Path $ProjectRoot ($layout.agentsDir -replace '/', '\')
    if (-not (Test-Path $agentsDir)) { New-Item -ItemType Directory -Force -Path $agentsDir | Out-Null }
    foreach ($entry in $resolvedList) {
        $desc = $skillBlurb[$entry.phase]
        if (-not $desc) { $desc = "Phase $entry.phase" }
        $body = New-PhaseAgentMarkdown -Phase $entry.phase -Model $entry.model `
            -AgentName $entry.agent -SkillName $entry.skill -Description $desc `
            -SkillsDir $layout.skillsDir -InvokePrefix $layout.invoke
        [System.IO.File]::WriteAllText(
            (Join-Path $agentsDir "$($entry.agent).md"),
            $body,
            [System.Text.UTF8Encoding]::new($false))
    }
}

($payload | ConvertTo-Json -Depth 6) | Set-Content -LiteralPath $outJson -Encoding UTF8

$refSrc = Join-Path $repoRoot "pipeline-reference.md"
if (Test-Path $refSrc) {
    Copy-Item -LiteralPath $refSrc -Destination (Join-Path $extDir "pipeline-reference.md") -Force
}

$installedScripts = Join-Path $extDir "scripts"
if (-not (Test-Path $installedScripts)) { New-Item -ItemType Directory -Force -Path $installedScripts | Out-Null }
Copy-Item -LiteralPath $MyInvocation.MyCommand.Path -Destination (Join-Path $installedScripts "Sync-ModelRouting.ps1") -Force

Write-Host "Model routing synced ($ExtensionId) for cursor-agent + codex."
Write-Host "  Config : $ConfigPath"
Write-Host "  JSON   : $outJson"
foreach ($layout in $layouts) { Write-Host "  Agents : $($layout.agentsDir)" }
foreach ($row in $resolvedList) {
    Write-Host ("  {0,-14} {1,-28} -> {2}" -f $row.phase, $row.configured, $row.model)
}
