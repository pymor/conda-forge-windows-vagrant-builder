# This is a PowerShell script for building a specified feedstock.

param (
    [Parameter(Mandatory=$true)][string]$feedstock
)

### Set-PSDebug -Trace 2  # for detailed debugging

$env:Path += ";c:\tools\miniconda3\Scripts"

$feedstock = $feedstock -replace '/', '\\'
cd c:\$feedstock
$config = @(Get-ChildItem .ci_support/win*vs2015*.yaml)[0]

conda build recipe -m c:\tools\miniconda3\conda_build_config.yaml -m $config
