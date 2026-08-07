<#
.SYNOPSIS
    Creates directories and writes boilerplate files for a new Terraform module.

.DESCRIPTION
    Owns the full scaffold create path: directories, relative naming/tags sources,
    file templates, and UTF-8 writes. Internal helpers live in this file only.

.PARAMETER name
    Module folder name (kebab-case).

.PARAMETER path
    Parent directory under modules/ (relative to repo root or absolute).

.PARAMETER description
    One-line purpose for headers / README.

.PARAMETER repoRoot
    Absolute path to the repository root.

.PARAMETER force
    When true, allows writing into an existing module directory.
#>
function New-TerraformModuleScaffold {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$path,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$description,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$repoRoot,

        [Parameter(Mandatory = $false)]
        [bool]$force = $false
    )

    # -------------------------------------------------------------------------
    # Internal: relative source under modules/ (e.g. ../../naming)
    # -------------------------------------------------------------------------
    function Get-RelativeTerraformSource {
        param(
            [string]$repoRoot,
            [string]$fromDir,
            [string]$targetName
        )

        $modulesDir = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'modules'))
        $fromFull = [System.IO.Path]::GetFullPath($fromDir)

        if (-not $fromFull.StartsWith($modulesDir, [System.StringComparison]::OrdinalIgnoreCase)) {
            throw "Module path must live under modules/: '$fromFull'."
        }

        $relativeUnderModules = $fromFull.Substring($modulesDir.Length).TrimStart('\', '/')
        $segments = @($relativeUnderModules -split '[\\/]' | Where-Object { $_ -ne '' })

        if ($segments.Count -eq 0) {
            return "./$targetName"
        }

        $up = ('../' * $segments.Count).TrimEnd('/')
        return "$up/$targetName"
    }

    # -------------------------------------------------------------------------
    # Internal: write one file as UTF-8 without BOM (CRLF)
    # -------------------------------------------------------------------------
    function Write-Utf8NoBomFile {
        param(
            [string]$filePath,
            [string]$content
        )

        $parentDir = Split-Path -Parent $filePath
        if (-not [string]::IsNullOrWhiteSpace($parentDir) -and -not (Test-Path -LiteralPath $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force -ErrorAction Stop | Out-Null
        }

        $utf8NoBom = New-Object System.Text.UTF8Encoding $false
        $normalised = $content -replace "`r`n", "`n" -replace "`n", "`r`n"
        [System.IO.File]::WriteAllText($filePath, $normalised, $utf8NoBom)
    }

    # -------------------------------------------------------------------------
    # Internal: build boilerplate hashtable (relative path -> content)
    # -------------------------------------------------------------------------
    function Get-TerraformModuleFileContent {
        param(
            [string]$name,
            [string]$description,
            [string]$relFromRepo,
            [string]$namingSourceFromModule,
            [string]$tagsSourceFromModule,
            [string]$tagsSourceFromExample
        )

        $nameSnake = $name -replace '-', '_'
        $namingModuleLabel = "${nameSnake}_name"
        $resourceTypePlaceholder = $name -replace '-', '_'
        $fence = '```'
        $bt = [char]96

        $versionsTf = @"
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0" # 4.x required: align with estate modules
    }
  }
}
"@

        $mainTf = @"
# ---------------------------------------------------------------------------
# $relFromRepo
#
# $description
#
# Conventions:
#   - Resource names from modules/naming - never hardcode names.
#   - Tags from var.tags (caller merges via modules/tags).
#   - location is always a variable; never bake in a region.
# ---------------------------------------------------------------------------

module "$namingModuleLabel" {
  source = "$namingSourceFromModule"

  # TODO(deploy): set resource_type to a key known by modules/naming
  # (e.g. "key_vault", "storage_account", "virtual_desktop_host_pool").
  resource_type   = "$resourceTypePlaceholder"
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
  description     = var.description
  unique_id       = var.unique_id
}

# TODO(deploy): replace with the real Azure resource(s).
# resource "azurerm_TODO" "this" {
#   name                = module.$namingModuleLabel.name
#   resource_group_name = var.resource_group_name
#   location            = var.location
#   tags                = var.tags
# }
"@

        $variablesTf = @'
variable "resource_group_name" {
  description = "Name of the resource group into which resources are deployed."
  type        = string
}

variable "location" {
  description = "Azure region for resources (e.g. \"uksouth\"). Never hardcode region."
  type        = string
}

# ---------------------------------------------------------------------------
# Naming inputs (passed through to modules/naming)
# ---------------------------------------------------------------------------

variable "subscription_id" {
  description = "Subscription / landing-zone segment used by the naming module (e.g. \"vdi\", \"conn\")."
  type        = string
  default     = ""
}

variable "environment" {
  description = "Environment segment used in names and tags (e.g. \"dev\", \"int\", \"prd\")."
  type        = string
}

variable "description" {
  description = "Description segment for the naming module (workload-specific label)."
  type        = string
  default     = ""
}

variable "unique_id" {
  description = "Uniqueness / instance id segment for the naming module (e.g. \"01\")."
  type        = string
  default     = ""
}

# ---------------------------------------------------------------------------
# Tags - caller supplies merged map from modules/tags
# ---------------------------------------------------------------------------

variable "tags" {
  description = "Merged tag map from modules/tags (pass module.tags.tags from the caller). Applied to all resources."
  type        = map(string)
  default     = {}
}
'@

        $outputsTf = @"
# TODO(deploy): expose ids / names needed by sibling modules or env stacks.
#
# output "id" {
#   description = "Resource ID of the primary resource."
#   value       = azurerm_TODO.this.id
# }
#
# output "name" {
#   description = "Name generated by modules/naming."
#   value       = module.$namingModuleLabel.name
# }
"@

        $readmeMd = @"
# $relFromRepo

$description

## Layout

$fence$("text")
$name/
  main.tf              # resources + modules/naming call
  variables.tf         # inputs (incl. tags from caller)
  outputs.tf           # outputs for consumers
  versions.tf          # terraform + azurerm constraints
  README.md
  examples/basic/      # smoke / usage example
  tests/               # placeholder (use examples/basic for local validate)
$fence

## Conventions

- **Names** - every resource name comes from [modules/naming]($namingSourceFromModule). Do not hardcode names.
- **Tags** - this module accepts $($bt)var.tags$($bt). The **caller** (env stack or example) composes the map with [modules/tags]($tagsSourceFromModule) and passes $($bt)tags = module.tags.tags$($bt).
- **Region** - $($bt)location$($bt) is always a variable; never bake in a region.

## Naming integration (inside this module)

$fence$("hcl")
module "$namingModuleLabel" {
  source = "$namingSourceFromModule"

  resource_type   = "$resourceTypePlaceholder" # TODO: map to a naming resource_type key
  location        = var.location
  environment     = var.environment
  subscription_id = var.subscription_id
  description     = var.description
  unique_id       = var.unique_id
}

# resource "azurerm_TODO" "this" {
#   name = module.$namingModuleLabel.name
#   tags = var.tags
#   ...
# }
$fence

## Tags integration (caller / env stack)

Resource modules do **not** call $($bt)modules/tags$($bt) themselves. The caller merges tags and passes them in:

$fence$("hcl")
module "tags" {
  source = "$tagsSourceFromExample" # from examples/basic; adjust for env stacks

  workload    = "vdi-platform"
  environment = "dev"
  region      = "uksouth"

  mandatory = {
    costCentre             = "CC-0000"
    securityClassification = "Internal"
    resourceOwner          = "platform@example.com"
    CMDB_AppID             = "APP-00000"
  }
}

module "$nameSnake" {
  source = "../.." # from examples/basic; env stacks use modules/<category>/$name

  resource_group_name = "rg-example"
  location            = "uksouth"
  environment         = "dev"
  subscription_id     = "vdi"
  description         = "example"
  unique_id           = "01"

  tags = module.tags.tags
}
$fence

## Azure resources

- TODO(deploy): list $($bt)azurerm_*$($bt) resources created by this module.

## Outputs

- TODO(deploy): document outputs once defined in $($bt)outputs.tf$($bt).

See [examples/basic](examples/basic) for usage.
"@

        $exampleProvidersTf = @'
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0, < 5.0.0" # 4.x required: align with estate modules
    }
  }
}

provider "azurerm" {
  features {}
}
'@

        $exampleMainTf = @"
# Basic example - wires modules/tags and the scaffolded module.
# From this directory: terraform init -backend=false && terraform validate
# (validate may fail until TODO(deploy) resources are filled in.)

module "tags" {
  source = "$tagsSourceFromExample"

  workload    = "vdi-platform"
  environment = "dev"
  region      = "uksouth"

  mandatory = {
    costCentre             = "CC-0000"
    securityClassification = "Internal"
    resourceOwner          = "platform@example.com"
    CMDB_AppID             = "APP-00000"
  }
}

module "$nameSnake" {
  source = "../.."

  resource_group_name = "rg-example-dev"
  location            = "uksouth"
  environment         = "dev"
  subscription_id     = "vdi"
  description         = "example"
  unique_id           = "01"

  tags = module.tags.tags
}

# output "id" {
#   value = module.$nameSnake.id
# }
"@

        $testsReadme = @"
# tests

Automated module tests are not wired yet for this scaffold.

Use [examples/basic](../examples/basic) for local smoke checks:

$fence$("powershell")
cd examples/basic
terraform init -backend=false
terraform validate
$fence
"@

        return @{
            'versions.tf'                 = $versionsTf
            'main.tf'                     = $mainTf
            'variables.tf'                = $variablesTf
            'outputs.tf'                  = $outputsTf
            'README.md'                   = $readmeMd
            'examples\basic\providers.tf' = $exampleProvidersTf
            'examples\basic\main.tf'      = $exampleMainTf
            'tests\README.md'             = $testsReadme
        }
    }

    # -------------------------------------------------------------------------
    # Resolve destination paths
    # -------------------------------------------------------------------------
    $parentPath = if ([System.IO.Path]::IsPathRooted($path)) {
        [System.IO.Path]::GetFullPath($path)
    }
    else {
        [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
    }

    $moduleRoot = Join-Path $parentPath $name
    $exampleBasic = Join-Path $moduleRoot 'examples\basic'
    $testsDir = Join-Path $moduleRoot 'tests'
    $relFromRepo = $moduleRoot.Substring($repoRoot.Length).TrimStart('\', '/').Replace('\', '/')

    # -------------------------------------------------------------------------
    # Create directories, build templates, write files
    # -------------------------------------------------------------------------
    try {
        if ((Test-Path -LiteralPath $moduleRoot) -and $force) {
            Write-Warning "Overwriting existing module at '$moduleRoot'."
        }

        New-Item -ItemType Directory -Path $moduleRoot -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType Directory -Path $exampleBasic -Force -ErrorAction Stop | Out-Null
        New-Item -ItemType Directory -Path $testsDir -Force -ErrorAction Stop | Out-Null

        $namingSourceFromModule = Get-RelativeTerraformSource -repoRoot $repoRoot -fromDir $moduleRoot -targetName 'naming'
        $tagsSourceFromModule = Get-RelativeTerraformSource -repoRoot $repoRoot -fromDir $moduleRoot -targetName 'tags'
        $tagsSourceFromExample = Get-RelativeTerraformSource -repoRoot $repoRoot -fromDir $exampleBasic -targetName 'tags'

        $fileContents = Get-TerraformModuleFileContent `
            -name $name `
            -description $description `
            -relFromRepo $relFromRepo `
            -namingSourceFromModule $namingSourceFromModule `
            -tagsSourceFromModule $tagsSourceFromModule `
            -tagsSourceFromExample $tagsSourceFromExample

        foreach ($relativePath in ($fileContents.Keys | Sort-Object)) {
            $absolutePath = Join-Path $moduleRoot $relativePath
            Write-Utf8NoBomFile -filePath $absolutePath -content $fileContents[$relativePath]
            Write-Verbose "Wrote $absolutePath"
        }
    }
    catch {
        throw "Failed to scaffold module at '$moduleRoot'. $($_.Exception.Message)"
    }

    # Caller uses this path for the success summary.
    return $moduleRoot
}
