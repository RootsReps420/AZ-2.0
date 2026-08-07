<#
.SYNOPSIS
    Validates parameters for New-TerraformModule.ps1 before any files are written.

.PARAMETER name
    Proposed module folder name (kebab-case).

.PARAMETER path
    Parent directory for the module (relative to repo root or absolute).

.PARAMETER description
    One-line module purpose string.

.PARAMETER repoRoot
    Absolute path to the repository root.

.PARAMETER force
    When true, an existing module directory may be overwritten later.
#>
function Test-TerraformModuleParameter {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$name,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$path,

        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$description,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$repoRoot,

        [Parameter(Mandatory = $false)]
        [bool]$force = $false
    )

    $errors = New-Object System.Collections.Generic.List[string]

    # --- name ---
    if ([string]::IsNullOrWhiteSpace($name)) {
        $errors.Add("Parameter 'name' is required and cannot be empty.")
    }
    elseif ($name -notmatch '^[a-z][a-z0-9-]*$') {
        $errors.Add("Parameter 'name' must be kebab-case (e.g. 'storage-blob'). Received: '$name'.")
    }
    elseif ($name.Length -gt 64) {
        $errors.Add("Parameter 'name' must be 64 characters or fewer. Received length: $($name.Length).")
    }

    # --- path ---
    if ([string]::IsNullOrWhiteSpace($path)) {
        $errors.Add("Parameter 'path' is required and cannot be empty.")
    }
    else {
        # Resolve relative paths against the repo root.
        $resolvedParent = if ([System.IO.Path]::IsPathRooted($path)) {
            [System.IO.Path]::GetFullPath($path)
        }
        else {
            [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
        }

        $modulesDir = [System.IO.Path]::GetFullPath((Join-Path $repoRoot 'modules'))

        # Parent must sit on or under modules/ (e.g. modules\core).
        $underModules = $resolvedParent.StartsWith(
            $modulesDir,
            [System.StringComparison]::OrdinalIgnoreCase
        )
        if (-not $underModules) {
            $errors.Add("Parameter 'path' must resolve under '$modulesDir'. Resolved: '$resolvedParent'.")
        }

        # Block path traversal / unexpected characters in the relative path.
        if ($path -match '\.\.') {
            $errors.Add("Parameter 'path' must not contain '..' segments.")
        }
    }

    # --- description ---
    if ([string]::IsNullOrWhiteSpace($description)) {
        $errors.Add("Parameter 'description' cannot be empty or whitespace.")
    }
    elseif ($description.Length -gt 256) {
        $errors.Add("Parameter 'description' must be 256 characters or fewer. Received length: $($description.Length).")
    }

    # --- collision (informational rule when -force is not set) ---
    if ($errors.Count -eq 0 -and -not [string]::IsNullOrWhiteSpace($name) -and -not [string]::IsNullOrWhiteSpace($path)) {
        $resolvedParent = if ([System.IO.Path]::IsPathRooted($path)) {
            [System.IO.Path]::GetFullPath($path)
        }
        else {
            [System.IO.Path]::GetFullPath((Join-Path $repoRoot $path))
        }
        $moduleRoot = Join-Path $resolvedParent $name

        if ((Test-Path -LiteralPath $moduleRoot) -and -not $force) {
            $errors.Add("Module directory already exists: '$moduleRoot'. Pass -force to overwrite.")
        }
    }

    # --- repo root sanity ---
    if (-not (Test-Path -LiteralPath $repoRoot)) {
        $errors.Add("Repository root does not exist: '$repoRoot'.")
    }
    elseif (-not (Test-Path -LiteralPath (Join-Path $repoRoot 'modules'))) {
        $errors.Add("Repository root is missing a modules/ folder: '$repoRoot'.")
    }

    if ($errors.Count -gt 0) {
        $message = "Parameter validation failed:`n - " + ($errors -join "`n - ")
        throw $message
    }
}
