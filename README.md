# Vagrant-based conda-forge Windows Builder

This repo provides a system that lets you use a Linux machine to build
[conda-forge](https://conda-forge.org/) software packages for the
[Windows](https://www.microsoft.com/en-us/windows) operating system. It does
this by setting up a [Vagrant](https://www.vagrantup.com/) “box” (virtual
machine) that does the actual package building.


## Preparation

In order to use this system, you of course need to have Vagrant installed.

You will also need about 20 GiB of free disk space to store the various
virtual machine images used in this process.

You also need to specify or create the directory that will contain the files
for the various feedstocks that you intend to build within the Windows Vagrant
box. This directory should be an item named `feedstocks` created in the
directory containing this file, but it can be a symbolic link to some other
directory, e.g.:

```
ln -s ~/src/conda feedstocks
```

The Vagrant box will only be able to access directories below this prefix, so
choose something that will contain all of the feedstock directories you care
about.

Finally, you will need to create a new “base box” that modifies
[the official Microsoft VM images](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/)
to work with SSH. The files and instructions for doing so are in
[the `msedgewin10_newssh` subdirectory](./msedgewin10_newssh/README.md).


## Usage

All tools provided by this repository are accessed through the script
`./driver.sh`, which provides various “subcommands” like `git`.

The first subcommand you must run is `setup`. You must give it the name of the
custom base box created using the steps described in
[the `msedgewin10_newssh` subdirectory](./msedgewin10_newssh/README.md).
An example name of the resulting box might be `msedgewin10_newssh_17.17134`.
Just pass that name as an argument to the `setup` command:

```
./driver.sh setup msedgewin10_newssh_17.17134
```

Once that’s done, the most important subcommand is `build`, which uses
`conda-build` to try building a package in the Windows box. You pass it the
path to a feedstock directory, *which must be relative to the “feedstocks”
directory* set up above:

```
./driver.sh build feedstocks/fontconfig-feedstock
```

The first time you run this command (or any others that interact with the
Vagrant box), Vagrant will set up the builder box, which involves some large
downloads and can take a while. Once the box has been set up, however,
starting it back up is relatively quick.

**Note**: you might need to run `vagrant reload` after first booting up the
box, to get some system settings changes to apply on a reboot.

Also note that you must have
[rerendered](https://github.com/conda-forge/staged-recipes/wiki/conda-smithy-rerender)
the feedstock so that Conda-build actually thinks that there is anything to do
for Windows. Specifically, there should be files within the feedstock whose
names match the shell glob `.ci_support/win_*.yaml`. You can do this rerender
on your Linux box.

There are also other helper commands. One will perform a package search within
the Windows box, which is helpful for investigating support libraries provided
by MSYS2. For example:

```
./driver.sh search gettext
```

The command `sshfs` will mount the C: drive of the Windows machine on the
specified local path (creating it if necessary) using the
[sshfs](https://github.com/libfuse/sshfs) filesystem (i.e., a userspace
network mount using SFTP behind the scenes). This can be an absolute lifesaver
since the Windows SSH terminal emulator is not correct enough to run an
interactive text editor.

```
./driver.sh sshfs winfs
```

Use the command `fusermount -u {local_path}` to manually unmount the SSHFS
filesystem. Note that Emacs has trouble saving files within such a mount: when
overwriting an existing file, it wants to use the `O_TRUNC` flag, but it seems
that the Windows SFTP subsystem doesn’t support the truncation operation.
Sadly, setting
[file-precious-flag](https://www.gnu.org/software/emacs/manual/html_node/elisp/Saving-Buffers.html)
doesn’t seem to help. Vim can save files just fine.

Another one will print out the URLs to the tarballs associated with a particular
package, which is helpful for investigating exactly which files it provides:

```
./driver.sh urls m2w64-gettext
```

The `purge` command will run `conda build purge`:

```
./driver.sh purge
```

The `pull` command will copy a *Windows-format* path to the directory
containing this file. Note that you must properly quote the Windows path
so that your Unix shell doesn’t eat the backslashes it likely contains.

```
./driver.sh pull 'C:\mc3\conda-bld\win-64\freetype-2.9.1-he8b6a0d_4.tar.bz2'
```


## More details

By default, running `vagrant ssh` will drop you into a PowerShell in the
Vagrant box. The box is provisioned with a batch file named `condabash`, that
will in turn drop you into a bash shell configured with the relevant Conda
environment. The provisioning process installs the MSYS2 `posix` package,
which provides an environment that is relatively close to a standard Unix
shell. The conda-forge install lives in `C:\mc3`, A.K.A `/c/mc3` according to
Unix tools. (This is not the Chocolatey default due to a nasty problem with
the case-insensitivity of the Windows filesystem.)
