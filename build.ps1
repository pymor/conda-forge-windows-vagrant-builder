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
   $yamls = @(Get-ChildItem .ci_support/win*.yaml)
   if ($yamls.Length -gt 0) {
      $config = $yamls[0]
   } else {
      throw "no config YAML .ci_support/win*.yaml found -- did you rerender for Windows?"
   }
}

$env:VS140COMNTOOLS = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\Tools\"

conda build recipe -m $config
