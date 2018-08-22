# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

Vagrant.configure("2") do |config|
  config.vm.box = "senglin/win-10-enterprise-vs2015community"
  config.vm.box_version = "1.0.0"
  config.vm.guest = :windows
  config.vm.communicator = :winrm

  config.vm.provision :shell, path: "provision.ps1"

  config.vm.synced_folder "@FEEDSTOCKS@", "/feedstocks"
end
