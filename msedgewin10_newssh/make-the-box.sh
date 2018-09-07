#! /bin/sh

cd $(dirname "$0")

if [ ! -f .cfg_base_box ] ; then
    echo >&2 "error: you must download the stock Microsoft image and create the "
    echo >&2 "       file \".cfg_base_box\" first -- see README.md"
    exit 1
fi

pristine_box=$(cat .cfg_base_box)
newssh_box=$(echo "$pristine_box" |sed -e 's/pristine/newssh/')

if [ "$newssh_box" = "$pristine_box" ] ; then
    echo >&2 "error: this script can only work if your base box's name includes the phrase \"pristine\""
    exit 1
fi

set -e -x
vagrant up
vagrant halt
vagrant package --output "${newssh_box}.box" --vagrantfile Vagrantfile.package
vagrant box add --force --name "${newssh_box}" "${newssh_box}.box"
rm "${newssh_box}.box"
