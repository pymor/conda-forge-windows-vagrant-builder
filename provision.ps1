# This is a PowerShell script that provisions the builder box.

### Set-PSDebug -Trace 2  # for detailed debugging

Set-ExecutionPolicy Bypass -Scope Process -Force

# Chocolatey is preinstalled, but needs updating in order to actually install
# stuff correctly.

$env:ChocolateyInstall = "$($env:SystemDrive)\ProgramData\Chocolatey"
$ChocoInstallPath = "$($env:ChocolateyInstall)\bin"
$env:Path += ";$ChocoInstallPath"

if (!(Test-Path("$ChocoInstallPath\choco.exe"))) {
   iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco feature enable -n allowGlobalConfirmation
choco upgrade chocolatey

# Installing Miniconda3 is now straightforward:

choco install miniconda3
$env:Path += ";c:\tools\miniconda3\Scripts"

# Finally, the conda-forge build environment:

conda config --add channels conda-forge
conda update --all -y
conda install conda-build conda-forge-pinning -y
