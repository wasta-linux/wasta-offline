#!/bin/bash

# This script simplifies the command needed to create .mo files.

# Script arguments.
app=$1
if [[ ! $app =~ wasta-(offline)|(snap-manager) ]]; then
    read -p "Which app? [wasta-offline|wasta-snap-manager]: " app
fi
lang=$2
if [[ ! $lang =~ [a-z]{2} ]]; then
    read -p "Which language? [am|es|fr|ru|...]: " lang
fi

# Package variables.
script_dir="$(dirname $0)"
pkg_dir="${script_dir%/*}"
inst_dir="${pkg_dir}/install-files"
po_dir="${inst_dir}/${app}/po"
locale_dir="${inst_dir}/locale"

# Command variables.
src="${po_dir}/${lang}.po"
dest_file="${app}.mo"
dest_dir="${locale_dir}/${lang}/LC_MESSAGES"

# Create .mo file.
msgfmt -o "${dest_dir}/${dest_file}" "${src}"
ec=$?

if [[ $ec -ne 0 ]]; then
    echo "Error creating $dest_file. Exiting."
    exit $ec
fi

echo -e "\nCreated ${dest_file} in ${dest_dir}.\n"

read -p "Copy to ~/.local/... for testing? [y|n]: " answer
if [[ $answer == 'y' ]]; then
    loc_msg_dir="$HOME/.local/share/locale/${lang}/LC_MESSAGES"
    cp "${dest_dir}/${dest_file}" "${loc_msg_dir}/"
    echo "${dest_file} copied to ${loc_msg_dir}."
fi
