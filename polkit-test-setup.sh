#!/bin/bash

### This script "installs" the polkit authentication and binary files in order to test WSM. ###

# This script needs sudo privileges.
# ---------------------------------------------------------------------------
if [[ $(id -u) -ne 0 ]]; then
    echo "This script needs to be run with root privileges. Exiting."
    exit 1
fi

BASE=$(realpath $(dirname $0))
installs=install-files
BIN=/usr/bin
POLKIT=/usr/share/polkit-1/actions
bin=wasta-snap-manager-root
bin2=wasta-snap-manager-2
action=org.wasta.apps.wasta-snap-manager-root.policy
action2=org.wasta.apps.wasta-snap-manager-2.policy

bin3=wasta-offline-root
action3=org.wasta.apps.wasta-offline.policy

if [[ ! $1 ]]; then
    # Create symlink for binary.
    cd "$BIN"
    if [[ ! -e ./$bin ]]; then
        cp -s "$BASE"/"$installs"/bin/"$bin" .
        echo "symlink for $BASE/$installs/bin/$bin created at $BIN"

	cp -s "$BASE"/"$installs"/bin/"$bin3" .
        echo "symlink for $BASE/$installs/bin/$bin3 created at $BIN"
    fi
    # Create symlink for polkit file.
    cd "$POLKIT"
    if [[ ! -e ./$action ]]; then
        cp -s "$BASE"/"$installs"/"$action" .
        echo "symlink for $BASE/$installs/$action created at $POLKIT"

        cp -s "$BASE"/"$installs"/"$action3" .
        echo "symlink for $BASE/$installs/$action3 created at $POLKIT"
    fi

elif [[ $1 == '-d' ]]; then
    # Remove symlinks.
    if [[ -L $BIN/$bin ]]; then
        rm "$BIN"/"$bin"
        echo "symlink at $BIN/$bin removed"

        rm "$BIN"/"$bin3"
        echo "symlink at $BIN/$bin3 removed"
    fi
    if [[ -L "$POLKIT"/"$action" ]]; then
        rm "$POLKIT"/"$action"
        echo "symlink at $POLKIT/$action removed"

        rm "$POLKIT"/"$action3"
        echo "symlink at $POLKIT/$action3 removed"
    fi
elif [[ $1 == '-h' ]]; then
    echo "Usage: $0 [-h | -d]"
    echo "Simulate installation by creating symlinks for $bin, $bin3"
    echo "$action, and $action3."
    echo "(These links will be removed if the -d option is passed.)"
    echo "The corresponding wasta-offline script still needs to be run explicitly;"
    echo "i.e. \$ $BASE/install-files/bin/wasta-offline."
fi

exit 0
