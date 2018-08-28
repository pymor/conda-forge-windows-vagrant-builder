# This is a PowerShell script for getting the URLs associated with some
# package query.

param (
    [Parameter(Mandatory=$true)][string]$query
)

### Set-PSDebug -Trace 2  # for detailed debugging

# helper to turn PSCustomObject into a list of key/value pairs
# https://stackoverflow.com/a/33521853/3760486
function Get-ObjectMembers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key"}
    }
}

conda info --json $query |ConvertFrom-Json |Get-ObjectMembers |foreach {
    $package = $_.Key

    foreach ($rec in $_.Value) {
        Write-Output "$package`t$($rec.version)`t$($rec.build)`t$($rec.arch)`t$($rec.url)"
    }
}
