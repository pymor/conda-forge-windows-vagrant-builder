#! /bin/bash

function vagrant_up () {
    if vagrant status |grep ^default |grep -q running ; then
        :
    else
        echo "Starting the Vagrant VM ..."
        vagrant up
    fi
}


function cmd_build () {
    # Validate arg

    feedstock="$1"

    if [ ! -d "$feedstock" ] ; then
        echo >&2 "error: feedstock argument \"$feedstock\" must reference a directory"
        exit 1
    fi

    case "$feedstock" in
        feedstocks/*) ;;
        *) echo >&2 "error: feedstock argument \"$feedstock\" must begin with \"feedstocks/\""
           exit 1 ;;
    esac

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the path of the feedstock to build"
        exit 1
    fi

    # OK, we can get going.

    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp
    logfile="$feedstock"/windows-build.log

    echo "Building; logs also captured to \"$logfile\" ..."
    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -File c:\\\\vagrant\\\\build.ps1 -feedstock "$feedstock" |& tee "$logfile"
    rm -f $cfg_tmp
}


function cmd_pull () {
    # Validate arg

    windows_path="$1"

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the path of the file to copy"
        exit 1
    fi

    # OK, we can get going.

    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp

    windows_path=$(echo "$windows_path" |sed -e 's|\\|\\\\|g')

    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -Command "cp \"$windows_path\" c:\\\\vagrant"
    rm -f $cfg_tmp
}


function cmd_purge () {
    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp

    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -Command "c:\\\\mc3\\\\scripts\\\\conda build purge"
    rm -f $cfg_tmp
}


function cmd_search () {
    # Validate arg

    term="$1"

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the search term"
        exit 1
    fi

    # OK, we can get going.

    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp
    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -Command "c:\\\\mc3\\\\scripts\\\\conda search *$term*"
    rm -f $cfg_tmp
}


function cmd_setup () {
    # Validate arg

    base_box="$1"

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the base box name"
        exit 1
    fi

    # OK, we can get going.

    if [ ! -e feedstocks ] ; then
        echo >&2 "error: create a directory or symbolic link here named \"feedstocks\""
        echo >&2 "       inside of which your feedstocks will reside. For example,"
        echo >&2 "          \"ln -s ~/sw/feedstocks feedstocks\""
        exit 1
    fi

    echo "$base_box" >.cfg_base_box
    echo "Setup complete."
    return 0
}


function cmd_sshfs () {
    # Validate arg

    local_path="$1"

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the local path"
        exit 1
    fi

    # OK, we can get going. Note: My sshfs has a bug where the path to the SSH
    # config file must be absolute. Other options:
    #
    # idmap=user - try to map same-user IDs between filesystems; seems desirable
    # transform_symlinks - make absolute symlinks relative; also seems desirable
    # workaround=rename - make it so that rename-based overwrites work; needed
    #   for Vim to save files

    mkdir -p "$local_path"
    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp
    sshfs -F $(realpath $cfg_tmp) -o idmap=user -o transform_symlinks \
          -o workaround=rename default:/C: "$local_path"
    rm -f $cfg_tmp
}


function cmd_urls () {
    # Validate arg

    term="$1"

    if [ $# -ne 1 ] ; then
        echo >&2 "error: unexpected extra argument(s) after the search term"
        exit 1
    fi

    # OK, we can get going.

    vagrant_up
    cfg_tmp=$(mktemp)
    vagrant ssh-config >$cfg_tmp
    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -File c:\\\\vagrant\\\\urls.ps1 -query "\"$term\""
    rm -f $cfg_tmp
}


function usage () {
    echo "Usage: $0 COMMAND [arguments...]  where COMMAND is one of:"
    echo ""
    echo "   build    Build a Windows package"
    echo "   pull     Copy a file from the box to the local filesystem"
    echo "   purge    Run \"conda build purge\" in the Windows box"
    echo "   search   Search by package name on the Windows box"
    echo "   setup    Set up the system for operation"
    echo "   sshfs    Mount the Windows filesystem locally using sshfs"
    echo "   urls     Print URLs associated with a Windows package search"
    echo ""
    exit 0
}


# Dispatcher.

command="$1"

if [ -z "$command" ] ; then
    usage
fi

shift

case "$command" in
    build)
        cmd_build "$@" ;;
    pull)
        cmd_pull "$@" ;;
    purge)
        cmd_purge "$@" ;;
    search)
        cmd_search "$@" ;;
    setup)
        cmd_setup "$@" ;;
    sshfs)
        cmd_sshfs "$@" ;;
    urls)
        cmd_urls "$@" ;;
    *)
        echo >&2 "error: unrecognized COMMAND \"$command\""
        usage ;;
esac
