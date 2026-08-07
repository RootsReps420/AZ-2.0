<#
.SYNOPSIS
    Dot-sources every function script in this folder into the caller's scope.

.DESCRIPTION
    Loads reusable helpers for scripts under scripts/. Skips this loader file
    itself so it can be called safely from entry-point scripts.
#>

# Absolute path of the functions folder (this file's directory).
$functionsRoot = $PSScriptRoot

# Enumerate sibling .ps1 files; skip this loader so we do not recurse.
$functionFiles = Get-ChildItem -LiteralPath $functionsRoot -Filter '*.ps1' -File |
    Where-Object { $_.Name -ne 'Import-ScriptFunctions.ps1' } |
    Sort-Object Name

if (-not $functionFiles) {
    throw "No function scripts found under '$functionsRoot'."
}

# Dot-source each file so functions become available to the caller.
foreach ($functionFile in $functionFiles) {
    . $functionFile.FullName
}
