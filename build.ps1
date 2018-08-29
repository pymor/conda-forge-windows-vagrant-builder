# This is a PowerShell script for building a specified feedstock.

param (
    [Parameter(Mandatory=$true)][string]$feedstock
)

### Set-PSDebug -Trace 2  # for detailed debugging

$feedstock = $feedstock -replace '/', '\\'
cd c:\$feedstock
$yamls = @(Get-ChildItem .ci_support/win*vs2015*.yaml)

if ($yamls.Length -gt 0) {
   $config = $yamls[0]
} else {
   $config = @(Get-ChildItem .ci_support/win*.yaml)[0]
}

conda build recipe -m $config
