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
        -Command "c:\\\\tools\\\\miniconda3\\\\scripts\\\\conda search *$term*"
    rm -f $cfg_tmp
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
        -File c:\\\\vagrant\\\\urls.ps1 -query "$term"
    rm -f $cfg_tmp
}


function usage () {
    echo "Usage: $0 COMMAND [arguments...]  where COMMAND is one of:"
    echo ""
    echo "   build    Build a Windows package"
    echo "   search   Search by package name on the Windows box"
    echo "   setup    Set up the system for operation"
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
    search)
        cmd_search "$@" ;;
    setup)
        cmd_setup "$@" ;;
    urls)
        cmd_urls "$@" ;;
    *)
        echo >&2 "error: unrecognized COMMAND \"$command\""
        usage ;;
esac
