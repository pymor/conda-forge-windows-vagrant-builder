# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

begin
  base_box = File.read('.cfg_base_box').strip()
rescue Errno::ENOENT
  raise 'configure this box by recording the base box name in ".cfg_base_box" (see README.md)'
end

Vagrant.configure("2") do |config|
  config.vm.box = base_box

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
