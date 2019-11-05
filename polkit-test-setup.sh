#!/bin/bash

### This script "installs" the polkit authentication and binary files in order to test WSM. ###

# This script needs sudo privileges.
# ---------------------------------------------------------------------------
if [[ $(id -u) -ne 0 && ! $1 == '-h' ]]; then
    echo "This script needs to be run with root privileges. Exiting."
    exit 1
fi

BASE=$(realpath $(dirname $0))
BIN=/usr/bin
POLKIT=/usr/share/polkit-1/actions

bins=(
    wasta-snap-manager-root
    wasta-offline-root
)

actions=(
    org.wasta.apps.wasta-snap-manager-root.policy
    org.wasta.apps.wasta-offline.policy
)

if [[ ! $1 ]]; then
    # Create symlinks for binaries.
    cd "$BIN"
    for b in ${bins[@]}; do
        if [[ ! -e ./$b ]]; then
            cp -s "$BASE/install-files/bin/$b" .
            echo "$BASE/install-files/bin/$b -> $BIN"
        fi
    done

    # Create symlinks for polkit files.
    cd "$POLKIT"
    for a in ${actions[@]}; do
        if [[ ! -e ./$a ]]; then
            cp -s "$BASE/install-files/$a" .
            echo "$BASE/install-files/$a -> $POLKIT"
        fi
    done

elif [[ $1 == '-d' ]]; then
    # Remove symlinks for binaries.
    for b in ${bins[@]}; do
        if [[ -L $BIN/$b ]]; then
            rm "$BIN/$b"
            echo "symlink at $BIN/$b removed"
        fi
    done

    # Remove symlinks for polkit files.
    for a in ${actions[@]}; do
        if [[ -L $POLKIT/$a ]]; then
            rm "$POLKIT/$a"
            echo "symlink at $POLKIT/$a removed"
        fi
    done

elif [[ $1 == '-h' ]]; then
    echo "Usage: $0 [-h | -d]"
    echo
    echo "Simulate installation by creating symlinks for:"
    for b in ${bins[@]}; do
        echo -e "\t$b"
    done
    for a in ${actions[@]}; do
        echo -e "\t$a"
    done
    echo
    echo "(These links will be removed if the -d option is passed.)"
    echo "The corresponding wasta-offline script still needs to be run explicitly;"
    echo "i.e. \$ $BASE/install-files/bin/wasta-offline."
fi

exit 0
