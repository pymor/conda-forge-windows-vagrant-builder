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

# Installing Miniconda3 is now straightforward -- except that we MUST install
# it in a prefix whose name is all lowercase, since conda-build does
# case-sensitive searching for path prefixes when packaging and CMake likes to
# lowercasify the paths that it works with.

choco install miniconda3 --params="'/D:C:\mc3'"
$env:Path += ";C:\mc3\Scripts"

$k = 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment'
$path = (Get-ItemProperty -Path $k -Name PATH).path
$path = "$path;C:\mc3\Scripts"
Set-ItemProperty -Path $k -Name PATH -Value $path

# The conda-forge shell+build environment:

conda config --add channels conda-forge
conda update --all -y
conda install -y conda-build conda-forge-pinning m2w64-binutils m2-bzip2 m2-git m2-vim posix
conda clean -tipsy

# Finally, Visual Studio 2015 build tools. Note that with the "right"
# parameters this install can easily take an extremely long time and oodles of
# disk space.

choco install vcbuildtools --package-parameters "/InstallSelectableItems NativeLanguageSupport_VC"

# The Visual Studio installer has a somewhat infuriating bug where it
# apparently will just not install all files correctly. In particular, it
# often fails to install the debugging version of the C runtime DLL in all
# necessary locations. This hack gets things going better. The recommended
# workaround seems to be to just keep on uninstalling and reinstalling Visual
# Studio until it works, which is ... dumb.
#
# Ref: https://stackoverflow.com/q/33743493/3760486

cp "C:\Program Files (x86)\Windows Kits\10\bin\x64\ucrt\ucrtbased.dll" C:\Windows\System32

# Message to user

echo
echo "Now run \"vagrant reload\" for OS changes to take full effect."
