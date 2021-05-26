#!/usr/bin/env bash

set -euo pipefail

# reference URL: https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/
echo Downloading “MSEdge on Win10” for platform “Vagrant”
echo If the download fails visit https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/ and fix the link
wget -O box.zip https://az792536.vo.msecnd.net/vms/VMBuild_20190311/Vagrant/MSEdge/MSEdge.Win10.Vagrant.zip
unzip box.zip
rm box.zip
vagrant box add --name pyMOR_base "MSEdge - Win10.box"
vagrant up
vagrant package --output pyMOR_base_repack.box --vagrantfile Vagrantfile.package
vagrant box add --force --name pyMOR_base pyMOR_base_repack.box
rm pyMOR_base_repack.box
