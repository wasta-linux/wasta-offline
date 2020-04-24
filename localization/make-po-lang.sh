#!/bin/bash

# This script simplifies the command needed to create or update language-specific
#   .po files, eitherr:
#   1. by creating the file if it doesn't exist and setting the language.
#   2. or by adding new "messages" lines to an already-translated file.

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
app_path="${pkg_dir}/install-files/bin/${app}"
po_path="${pkg_dir}/install-files/${app}/po"

# Command variables.
timestamp=$(date +%Y%m%d-%H)
dest_file="$lang-draft-$timestamp.po"
dest_dir="${pkg_dir}/localization"
dest_path="${dest_dir}/${dest_file}"

# Create up-to-date <app>-msg.po file.
"${dest_dir}/make-po-base.sh" "${app}"


if [[ ! -e ${po_path}/${lang}.po ]]; then
    # Create initial <lang>-draft-<date>.po file.
    xgettext --package-name="wasta-offline" -L Shell -o "${dest_path}" "${app_path}"*
    ec=$?
    adj="new"
else
    # Create updated <lang>-draft-<date>.po file.
    xgettext --package-name="wasta-offline" -L Shell -x "${po_path}/${lang}.po" -o "${dest_path}" "${app_path}"*
    ec=$?
    adj="updated"
fi

if [[ $ec -eq 0 ]]; then
    if [[ ! -e ${dest_path} ]]; then
        # There were no new messages found.
        echo -e "\nNo new messages found, so $dest_file was not created.\n"
        exit 0
    else
        echo -e "\nCreated $adj $dest_file in $dest_dir.\n"
    fi
else
    echo "Error while creating $adj $dest_file file. Exiting."
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

# Set language.
orig='Language: '
new='Language: '"${lang}"
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

# Convert to .docx for DeepL translation.
libreoffice --convert-to "docx" --outdir "${dest_dir}" "${dest_path}"

exit 0
