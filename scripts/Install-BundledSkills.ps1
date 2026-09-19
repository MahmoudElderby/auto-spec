#!/usr/bin/env pwsh
<#
.SYNOPSIS
  Copy Auto Spec bundled skills (e.g. spec-portfolio) into Cursor or Codex skill dirs.
.EXAMPLE
  .\Install-BundledSkills.ps1 -ProjectRoot . -Integration cursor-agent
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = (Get-Location).Path,
    [ValidateSet("cursor-agent", "codex")]
    [string]$Integration = "cursor-agent",
    [string]$ExtensionPath = ""
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

if (-not $ExtensionPath) {
    $ExtensionPath = Join-Path $ProjectRoot ".specify\extensions\auto-spec"
}
if (-not (Test-Path $ExtensionPath)) {
    throw "Extension not found at $ExtensionPath. Run specify extension add first."
}

$skillsSrc = Join-Path $ExtensionPath "skills"
if (-not (Test-Path $skillsSrc)) {
    Write-Warning "No bundled skills at $skillsSrc"
    return
}

$destRoot = if ($Integration -eq "codex") { ".agents\skills" } else { ".cursor\skills" }
$destBase = Join-Path $ProjectRoot $destRoot
if (-not (Test-Path $destBase)) { New-Item -ItemType Directory -Force -Path $destBase | Out-Null }

Get-ChildItem -LiteralPath $skillsSrc -Directory | ForEach-Object {
    $name = $_.Name
    $dest = Join-Path $destBase $name
    if (Test-Path $dest) { Remove-Item -LiteralPath $dest -Recurse -Force }
    Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
    Write-Host "Installed bundled skill: $destRoot\$name"
}

$productDir = Join-Path $ProjectRoot ".specify\product"
if (-not (Test-Path $productDir)) {
    New-Item -ItemType Directory -Force -Path $productDir | Out-Null
    Write-Host "Created .specify/product/"
}
