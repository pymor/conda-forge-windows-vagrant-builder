# PowerShell script for provisioning a conda-forge builder box.

# Set-PSDebug -Trace 1 # debugging
Set-ExecutionPolicy Bypass -Scope Process -Force

# Install Chocolatey:

$env:ChocolateyInstall = "$($env:SystemDrive)\ProgramData\Chocolatey"
$ChocoInstallPath = "$($env:ChocolateyInstall)\bin"
$env:Path += ";$ChocoInstallPath"

if (!(Test-Path("$ChocoInstallPath\choco.exe"))) {
   iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

choco feature enable -n allowGlobalConfirmation
choco upgrade all

# Installing Miniconda3 is now straightforward:

choco install miniconda3
$env:Path += ";c:\tools\miniconda3\Scripts"

$k = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
$path = (Get-ItemProperty -Path $k -Name PATH).path
$path = "$path;C:\Tools\Miniconda3\Scripts"
Set-ItemProperty -Path $k -Name PATH -Value $path

# The conda-forge shell+build environment:

conda config --add channels conda-forge
conda update --all -y
conda install -y conda-build conda-forge-pinning m2-bzip2 m2-vim posix
conda clean -tipsy

# Finally, Visual Studio 2015 build tools. Note that with the "right"
# parameters this install can easily take an extremely long time and oodles of
# disk space.

choco install vcbuildtools --package-parameters "/InstallSelectableItems NativeLanguageSupport_VC"

# VS2017:
# choco install visualstudio2017buildtools --package-parameters
#   "--passive --locale en-US --add Microsoft.VisualStudio.Workload.VCTools"
