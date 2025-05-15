#!/bin/bash

# Get the absolute path of the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd)"

. $SCRIPT_DIR/utils.sh

# add_aliases(){
#     LINE_TO_ADD="source $SCRIPT_DIR/../aliases/*.aliases"
#     ZSHRC_FILE="$HOME/.zshrc"
#
#     # Check if the line exists
#     if ! grep -q "$LINE_TO_ADD" "$ZSHRC_FILE"; then
#         # Line does not exist, append it
#         echo "$LINE_TO_ADD" >> "$ZSHRC_FILE"
#         echo "Added '$LINE_TO_ADD' to $ZSHRC_FILE"
#     else
#         # Line exists
#         warning "$LINE_TO_ADD' already exists in $ZSHRC_FILE"
#     fi
#
# }
add_aliases(){
    local path="$ROOT_DIR/aliases/*.sh"
    local files=$(echo $path)
    LINE_TO_ADD=$(cat << EOF
for file in ${files}; do
    chmod +x \${file}
    source \${file}
done
EOF
)
    # LINE_TO_ADD="source ${SCRIPT_DIR}/../aliases/*.sh" # Still use this for adding
    # Use a more robust pattern for checking
    LINE_PATTERN="^source .*\/aliases\/\*\.sh$"
    ZSHRC_FILE="$HOME/.zshrc"

    # Check if a matching line exists
    if ! grep -q "$LINE_TO_ADD" "$ZSHRC_FILE"; then # Use -E for extended regex, though basic might work too
        # Line does not exist, append it (echo expands $SCRIPT_DIR here)
        echo "$LINE_TO_ADD" >> "$ZSHRC_FILE"
        echo "Added '$LINE_TO_ADD' (expanded) to $ZSHRC_FILE" # Add a note about expansion
    else
        # Line exists
        # Use the original LINE_TO_ADD in the warning message as it's what the user expects
        warning "$LINE_TO_ADD' already exists in $ZSHRC_FILE"
    fi

}
