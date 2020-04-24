#!/bin/bash

# This script simplifies the command needed to create blank .po files.

# Script arguments.
app=$1
if [[ ! $app =~ wasta-(offline)|(snap-manager) ]]; then
    read -p "Which app? [wasta-offline|wasta-snap-manager]: " app
fi

# Package variables.
script_dir="$(dirname $0)"
pkg_dir="${script_dir%/*}"
app_path="${pkg_dir}/install-files/bin/${app}"

# Command variables.
dest_file="${app}-msg.po"
dest_dir="${pkg_dir}/localization"
dest_path="${dest_dir}/${dest_file}"

xgettext --package-name="wasta-offline" -L Shell -o "${dest_path}" "${app_path}"
ec=$?

if [[ $ec -eq 0 ]]; then
    echo -e "\nCreated ${dest_file} in ${dest_dir}.\n"
else
    echo "Error while creating $dest_file file. Exiting."
    exit $ec
fi

# Fill in title.
orig='# SOME DESCRIPTIVE TITLE.'
new='# WASTA-OFFLINE TRANSLATION STRINGS'
sed -i -r "s/${orig}/${new}/" "${dest_path}"

# Fill in the charset.
orig='CHARSET'
new='UTF-8'
sed -i -r 's/'"${orig}"'/'"${new}"'/' "${dest_path}"

# Delete "FIRST AUTHOR" line.
orig="$(grep 'FIRST AUTHOR' "${dest_path}")"
sed -i -r '/'"${orig}"'/d' "${dest_path}"

# Delete "Copyright" line.
orig='YEAR THE PACKAGE'
sed -i -r '/^.*'"${orig}"'.*$/d' "${dest_path}"

# Delete various information lines.
orig="Project-Id-Version:"
sed -i -r '/^.*'"${orig}"'.*$/d' "${dest_path}"
orig="Report-Msgid-Bugs-To:"
sed -i -r '/^.*'"${orig}"'.*$/d' "${dest_path}"
orig="PO-Revision-Date:"
sed -i -r '/^.*'"${orig}"'.*$/d' "${dest_path}"
orig="Language-Team:"
sed -i -r '/^.*'"${orig}"'.*$/d' "${dest_path}"

exit $ec
