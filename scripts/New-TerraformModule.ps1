<#
.SYNOPSIS
    Scaffold a new Terraform module directory with standard files and boilerplate.

.DESCRIPTION
    Creates a complete module skeleton matching vdi-terraform conventions:
      main.tf, variables.tf, outputs.tf, versions.tf, README.md,
      examples/basic/, and tests/.

    Azure resource modules call modules/naming for names and accept var.tags
    from the caller (who composes tags via modules/tags).

    Run locally from the repo root - not invoked by AzDo pipelines.

    Shared helpers live under scripts/functions/ and are loaded by this script.

.PARAMETER name
    Module folder name in kebab-case (e.g. "storage-blob").

.PARAMETER path
    Parent directory for the module (e.g. "modules\core", "modules\avd").

.PARAMETER description
    One-line purpose injected into main.tf and README.md headers.

.PARAMETER force
    Overwrite an existing module directory if present.

.EXAMPLE
    .\scripts\New-TerraformModule.ps1 -name storage-blob -path modules\core -description "Blob storage for PERS workloads"

.EXAMPLE
    .\scripts\New-TerraformModule.ps1 -name my-brick -path modules\platform -force
#>

# ---------------------------------------------------------------------------
# Parameters (must appear at the top of the script after help comment)
# ---------------------------------------------------------------------------
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, HelpMessage = "Kebab-case module folder name, e.g. storage-blob")]
    [string]$name,

    [Parameter(Mandatory = $true, HelpMessage = "Parent path under modules/, e.g. modules\core")]
    [string]$path,

    [Parameter(Mandatory = $false)]
    [string]$description = "TODO: describe this module.",

    [Parameter(Mandatory = $false)]
    [switch]$force
)

# Fail fast on unset variables and terminate on cmdlet errors.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ---------------------------------------------------------------------------
# Load shared functions from scripts/functions/
# ---------------------------------------------------------------------------
$functionsLoader = Join-Path $PSScriptRoot 'functions\Import-ScriptFunctions.ps1'
if (-not (Test-Path -LiteralPath $functionsLoader)) {
    throw "Functions loader not found: '$functionsLoader'."
}
. $functionsLoader

# ---------------------------------------------------------------------------
# Resolve repository root (parent of scripts/)
# ---------------------------------------------------------------------------
try {
    $repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..') -ErrorAction Stop).Path
}
catch {
    throw "Unable to resolve repository root from script location '$PSScriptRoot'. $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# Validate parameters, then create the module scaffold
# ---------------------------------------------------------------------------
try {
    Test-TerraformModuleParameter `
        -name $name `
        -path $path `
        -description $description `
        -repoRoot $repoRoot `
        -force:([bool]$force)

    $moduleRoot = New-TerraformModuleScaffold `
        -name $name `
        -path $path `
        -description $description `
        -repoRoot $repoRoot `
        -force:([bool]$force)
}
catch {
    throw "New-TerraformModule failed. $($_.Exception.Message)"
}

# ---------------------------------------------------------------------------
# Success summary for the operator
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Created module scaffold:" -ForegroundColor Green
Write-Host "  $moduleRoot"
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Set resource_type in main.tf to a key known by modules/naming"
Write-Host "  2. Replace the TODO(deploy) resource stub with real azurerm resources"
Write-Host "  3. Fill outputs.tf and update README Azure resources / Outputs sections"
Write-Host "  4. Wire the module from an environments/<env>/... stack when ready"
Write-Host ""
