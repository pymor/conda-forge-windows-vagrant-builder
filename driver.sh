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

    echo "Building; logs also captured to \"build.log\" ..."
    ssh -F $cfg_tmp default \
        powershell -NoProfile -NoLogo -InputFormat None -ExecutionPolicy Bypass \
        -File c:\\\\vagrant\\\\build.ps1 -feedstock "$feedstock" |& tee build.log
}


function cmd_setup () {
    if [ ! -e feedstocks ] ; then
        echo >&2 "error: create a directory or symbolic link here named \"feedstocks\""
        echo >&2 "       inside of which your feedstocks will reside. For example,"
        echo >&2 "          \"ln -s ~/sw/feedstocks feedstocks\""
        exit 1
    fi

    real_feedstocks=$(cd feedstocks && pwd -P)
    if [ $? -ne 0 ] ; then
        echo >&2 "error: couldn\'t determine physical path to \"feedstocks\" directory"
        exit 1
    fi

    sed -e "s|@FEEDSTOCKS@|$real_feedstocks|g" Vagrantfile.in >Vagrantfile
    echo "Setup complete."
    return 0
}


function usage () {
    echo "Usage: $0 COMMAND [arguments...]  where COMMAND is one of:"
    echo ""
    echo "   build    Build a Windows package"
    echo "   setup    Set up the system for operation"
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
    setup)
        cmd_setup "$@" ;;
    *)
        echo >&2 "error: unrecognized COMMAND \"$command\""
        usage ;;
esac
