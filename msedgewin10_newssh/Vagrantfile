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
  config.vm.guest = :windows
  config.vm.boot_timeout = 1200
  config.vm.graceful_halt_timeout = 1200

  config.vm.communicator = 'ssh'
  config.ssh.username = "IEUser"
  config.ssh.password = "Passw0rd!"
  config.ssh.insert_key = false
  config.ssh.shell = 'sh -l'

  config.vm.provision "file", source: "vagrant_insecure_key.pub", destination: ".ssh/authorized_keys"

  config.vm.provision "shell",
                      binary: true,
                      privileged: false,
                      inline: 'powershell -InputFormat None -NoProfile -ExecutionPolicy Bypass -File c:\\\\vagrant\\\\provision.ps1'
end
