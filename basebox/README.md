# Nearly-Stock Windows 10 Vagrant Box with Better SSH

This directory provides a [Vagrant](https://www.vagrantup.com/) “box” (virtual
machine) running a nearly stock version of the Windows 10 operating system,
but with better SSH support than the Microsoft-provided boxes. Boxes deriving
from this one can provide truly headless control of a full-featured Windows VM
of known provenance from a host running Linux or macOS.

The context is that Microsoft
[provides free Windows VMs](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
that should be great for automatic software building. However, these VMs are
configured in such a way that makes them very hard to use in a
non-interactive/headless setting, especially if your host OS is Linux where
your only way to communicate with them is using
[SSH](https://en.wikipedia.org/wiki/Secure_Shell). In particular, the SSH
server drops you into a `sh` shell that has almost no useful commands
installed, and doesn’t provide full TTY support so that interactive usage is
extremely, extremely painful.

The files and methodology in this directory will yield a new “base box” that
has minimal modifications from the official VMs, but are much easier to
interact with. The SSH service will drop you into an interactive PowerShell,
and the box will be provision-able in an almost-standard way. You can then
derive your own purpose-specific boxes from this new base box.

## Instructions

Creating this box will require a download of about 4.5 GiB and, at its
high-water mark, consume about 30 GiB of hard disk space.

1. Go to the
   [official Microsoft VM page](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
   and download an image. Select a virtual machine type of “MSEdge on Win10”
   and a platform of “Vagrant”. Start downloading the file.
2. While that is happening, **make note of the VM version number**, which
   appears in the “Virtual machine” dropdown menu. Set the version number as a
   variable in your shell with a command like this:
   ```
   $ VMVERSION=17.17134 # <== change this, maybe!
   ```
   We’re assuming you’re running Linux here. The version shown is the most
   recent value as of late 2018.
3. Record this version in a configuration file that the
   [Vagrantfile](https://www.vagrantup.com/docs/vagrantfile/) will then look
   at:
   ```
   $ echo msedgewin10_pristine_$VMVERSION >.cfg_base_box
   ```
4. Your download should have created a file named `MSEdge.Win10.Vagrant.zip`.
   Unzip this in the directory containing this README. You should get a file
   named `MSEdge - Win10.box`. It is OK to delete the Zip file after this is
   done.
5. Run the following command to import this box into your Vagrant system as a
   “base box”, including the VM version in the name:
   ```
   $ vagrant box add --name msedgewin10_pristine_$VMVERSION "MSEdge - Win10.box"
   ```
6. Boot up the Vagrant machine defined in this directory, which will change some
   settings and upgrade the SSH server in the official VM image:
   ```
   $ vagrant up
   ```
   This will pop up a few complaints from PowerShell but the tail end of the output
   should not show any errors.
7. Export this Vagrant machine into its own new box file:
   ```
   $ vagrant package --output msedgewin10_newssh_$VMVERSION.box --vagrantfile Vagrantfile.package
   ```
   Note that this command bundles an internal Vagrantfile that predefines some settings
   that make it easier to configure derived boxes.
8. Finally, re-import your box as a new base box:
   ```
   $ vagrant box add --force --name msedgewin10_newssh_$VMVERSION msedgewin10_newssh_$VMVERSION.box
   ```
   You can delete the `.box` file after this step. You can also destroy the
   Vagrant machine used to create the new box with the command `vagrant
   destroy`. Lastly, you can remove the Vagrant box of the pristine Windows
   image with `vagrant box remove msedgewin10_pristine_$VMVERSION`.

The last three steps are automated in the script `make-the-box.sh`. It’s
recommended that you go through the full process manually the first time,
however, in case anything funky happens with your Vagrant setup.

If you create a derived box using this new box as base, you will be able to
SSH into it and get a pretty decent interactive PowerShell prompt. To
provision it with a PowerShell script, use the following parameters:

```
  config.vm.provision :shell,
                      binary: true,
                      privileged: false,
                      upload_path: "C:\\Windows\\Temp",
                      path: "provision.ps1"
```

Here, `provision.ps1` would be the name of a script file next to your Vagrantfile.


## Implementation Notes

This was *very* painful to get working.

I wanted to achieve headless, fully automated operation of Windows in a
Vagrant box from a Linux box. I soon discovered that this meant that there was
basically only one way to interact with the Windows VM: via `vagrant ssh`.
Ruled-out options are:

- `vagrant rdp` can work, but uses interactive graphics
- `vagrant powershell` refuses to work unless the *host* OS is Windows as
  well.
- There’s also WinRM. This is disabled on the stock Microsoft boxes and was
  much harder to enable than I realized. Vagrant can do *some* operations via
  WinRM, but fundamentally it also doesn’t let you interact with the box
  through a terminal.

In the VM images I tried, the interactive SSH shell is *incredibly* limited.
First, it doesn’t provide an actual (pseudo)TTY interface (i.e., `tty` prints
`not a tty`). This means that line editing barely works and programs that want
interactivity fail. Second, virtually no shell commands are provided. Commands
that are **missing** include `cp`, `more`, and `cat`. (Other images with
better SSH experiences might be out there. I didn't find anything that derived
directly from the official Microsoft box files, which is important to me for
reproducibility and trust.)
