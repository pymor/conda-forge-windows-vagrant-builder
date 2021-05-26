# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure("2") do |config|
  config.vm.box = pyMOR_base

  config.vm.provision :file,
                      source: "condabash.bat",
                      destination: "/Windows/condabash.bat"

  config.vm.provision :shell,
                      binary: true,
                      privileged: false,
                      upload_path: "C:\\Windows\\Temp",
                      path: "provision.ps1"

  config.vm.synced_folder "feedstocks", "/feedstocks"
end
