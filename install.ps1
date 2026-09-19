#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Bootstrap Spec Kit (if needed) and install Auto Spec. Supports Cursor and Codex.

.EXAMPLE
  .\install.ps1 -ProjectRoot C:\dev\my-app -Integration cursor-agent
  .\install.ps1 -ProjectRoot C:\dev\my-app -Integration codex
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [ValidateSet("cursor-agent", "codex")]
    [string]$Integration = "cursor-agent",
    [string]$ExtensionPath = "",
    [string]$FromUrl = "",
    [string]$SpecKitVersion = "v0.15.2",
    [switch]$SkipModelSync,
    [switch]$SkipSpecKitBootstrap
)

$ErrorActionPreference = "Stop"
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = "1"
[Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)

function Ensure-Uv {
    if (Get-Command uv -ErrorAction SilentlyContinue) { return }
    Write-Host "Installing uv..."
    try {
        Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1" -UseBasicParsing | Invoke-Expression
    } catch {
        throw "Could not install uv automatically. Install from https://docs.astral.sh/uv/ then re-run."
    }
    $uvPath = Join-Path $env:USERPROFILE ".local\bin\uv.exe"
    if (Test-Path $uvPath) { $env:PATH = "$(Split-Path $uvPath -Parent);$env:PATH" }
}

function Ensure-SpecifyCli {
    param([string]$Tag)
    Ensure-Uv
    if (-not (Get-Command specify -ErrorAction SilentlyContinue)) {
        Write-Host "Installing specify-cli ($Tag)..."
        uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@$Tag"
    } else {
        $ver = (specify version 2>&1 | Out-String)
        if ($ver -notmatch "0\.1[5-9]|0\.[2-9]") {
            Write-Host "Upgrading specify-cli to $Tag..."
            uv tool install specify-cli --force --from "git+https://github.com/github/spec-kit.git@$Tag"
        }
    }
    if (-not (Get-Command specify -ErrorAction SilentlyContinue)) {
        throw "specify CLI still not on PATH. Restart shell or add uv tools bin to PATH."
    }
}

function Ensure-SpecKitProject {
    param(
        [string]$Root,
        [string]$IntegrationKey
    )
    if (Test-Path (Join-Path $Root ".specify")) { return }

    Write-Host "Initializing Spec Kit in $Root (integration: $IntegrationKey)..."
    Push-Location $Root
    try {
        $initArgs = @(
            "init", ".",
            "--integration", $IntegrationKey,
            "--script", "ps",
            "--here", "--force", "--ignore-agent-tools"
        )
        if ($IntegrationKey -eq "codex") {
            $initArgs += @("--integration-options", "--skills")
        }
        & specify @initArgs
        if ($LASTEXITCODE -ne 0) { throw "specify init failed with exit code $LASTEXITCODE" }
    } finally {
        Pop-Location
    }
}

function Install-AutoSpecExtension {
    param(
        [string]$Root,
        [string]$ExtPath,
        [string]$Url
    )
    Push-Location $Root
    try {
        if ($Url) {
            specify extension add auto-spec --from $Url --force
        } else {
            specify extension add --dev $ExtPath --force
        }
    } finally {
        Pop-Location
    }
}

function Ensure-ModelsConfig {
    param([string]$Root, [string]$ExtPath)
    $extDir = Join-Path $Root ".specify\extensions\auto-spec"
    $modelsTarget = Join-Path $extDir "models.yml"
    if (-not (Test-Path $modelsTarget)) {
        foreach ($src in @(
                (Join-Path $extDir "models.template.yml"),
                (Join-Path $ExtPath "models.template.yml")
            )) {
            if (Test-Path $src) {
                Copy-Item -LiteralPath $src -Destination $modelsTarget -Force
                Write-Host "Created models.yml from template."
                break
            }
        }
    }
    $ref = Join-Path $ExtPath "pipeline-reference.md"
    if (Test-Path $ref) {
        if (-not (Test-Path $extDir)) { New-Item -ItemType Directory -Force -Path $extDir | Out-Null }
        Copy-Item -LiteralPath $ref -Destination (Join-Path $extDir "pipeline-reference.md") -Force
    }
}

$repoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ExtensionPath) { $ExtensionPath = $repoRoot }

$ProjectRoot = (Resolve-Path $ProjectRoot).Path
if (-not (Test-Path $ProjectRoot)) { New-Item -ItemType Directory -Force -Path $ProjectRoot | Out-Null }

if (-not $SkipSpecKitBootstrap) {
    Ensure-SpecifyCli -Tag $SpecKitVersion
    Ensure-SpecKitProject -Root $ProjectRoot -IntegrationKey $Integration
}

if (-not (Test-Path (Join-Path $ProjectRoot ".specify"))) {
    throw "Spec Kit project missing after bootstrap. Run with -SkipSpecKitBootstrap only if .specify/ already exists."
}

Write-Host "Installing Auto Spec extension..."
Install-AutoSpecExtension -Root $ProjectRoot -ExtPath $ExtensionPath -Url $FromUrl
$extDir = Join-Path $ProjectRoot ".specify\extensions\auto-spec"
$bundledSkills = Join-Path $extDir "scripts\Install-BundledSkills.ps1"
if (Test-Path $bundledSkills) {
    & $bundledSkills -ProjectRoot $ProjectRoot -Integration $Integration -ExtensionPath $extDir
}
Ensure-ModelsConfig -Root $ProjectRoot -ExtPath $ExtensionPath

if (-not $SkipModelSync) {
    $sync = Join-Path $ExtensionPath "scripts\Sync-ModelRouting.ps1"
    if (-not (Test-Path $sync)) {
        $sync = Join-Path $ProjectRoot ".specify\extensions\auto-spec\scripts\Sync-ModelRouting.ps1"
    }
    if (Test-Path $sync) {
        Write-Host "Syncing models (Cursor + Codex agent binders)..."
        & $sync -ProjectRoot $ProjectRoot
    }
}

Write-Host ""
Write-Host "Auto Spec installed (Spec Kit + extension)."
Write-Host "Integration: $Integration"
if ($Integration -eq "codex") {
    Write-Host "  `$speckit-auto-spec-portfolio  (multi-spec register first)"
    Write-Host "  `$speckit-auto-spec-run"
    Write-Host "  `$speckit-auto-spec-review"
    Write-Host "  `$speckit-auto-spec-sync-models"
} else {
    Write-Host "  /speckit-auto-spec-portfolio  (multi-spec register first)"
    Write-Host "  /speckit-auto-spec-run"
    Write-Host "  /speckit-auto-spec-review"
    Write-Host "  /speckit-auto-spec-sync-models"
}
