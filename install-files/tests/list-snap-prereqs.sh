#!/bin/bash

# PolicyKit root app path.
AS_ROOT=/usr/bin/wasta-snap-manager-root

# List all prerequisites of each snap in the offline snaps folder.
SNAPS_DIR=/media/$USER/WASTA-OL/wasta-offline/local-cache/snaps/

list_prerequisites() {
    # Find and list the given snap's prerequisites.
    snap_file="$1"
    unset snap_prereqs[@]
    declare -Ag snap_prereqs
    tmpd=$(mktemp -d)
    pkexec "$AS_ROOT" mount "${SNAPS_DIR}/${snap_file}" "$tmpd"

    yaml="${tmpd}/meta/snap.yaml"
    expr='s/.*:\s(.*)/\1/'
    base=$(cat "$yaml" | grep 'base:' | sed -r "$expr") # 0 or 1 line
    confinement=$(cat "$yaml" | grep 'confinement:' | sed -r "$expr") # 1 line
    prereqs=$(cat "$yaml" | grep 'default-provider:' | sed -r "$expr") # 0 to multiple lines


    # Add "default-provider" prereqs to array.
    if [[ $prereqs ]]; then
        for p in $prereqs; do
            snap_prereqs[$p]=''
        done

        echo $snap_file
        for p in ${!snap_prereqs[@]}; do
            echo -e "\t$p"
        done
        echo
    fi

    pkexec "$AS_ROOT" umount "$tmpd"
    rm -r "$tmpd"
 }

snaps=$(find $SNAPS_DIR -maxdepth 1 -name '*.snap')
for filepath in $snaps; do
    snap=${filepath##*/}
    list_prerequisites $snap
done
