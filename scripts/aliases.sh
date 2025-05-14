#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

add_aliases(){
    LINE_TO_ADD="source $SCRIPT_DIR/../aliases/base.aliases"
    ZSHRC_FILE="$HOME/.zshrc"

    # Check if the line exists
    if ! grep -q "$LINE_TO_ADD" "$ZSHRC_FILE"; then
        # Line does not exist, append it
        echo "$LINE_TO_ADD" >> "$ZSHRC_FILE"
        echo "Added '$LINE_TO_ADD' to $ZSHRC_FILE"
    else
        # Line exists
        warning "$LINE_TO_ADD' already exists in $ZSHRC_FILE"
    fi

}

