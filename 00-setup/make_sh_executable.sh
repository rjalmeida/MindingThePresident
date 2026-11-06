#!/bin/bash

# Directory to process (default is current directory)
TARGET_DIR=${1:-.}

# Check if the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
    echo "Error: Directory '$TARGET_DIR' does not exist."
    exit 1
fi

# List all files in the directory
echo "Listing all files in '$TARGET_DIR':"
ls -l "$TARGET_DIR"

# Make .sh files executable
echo "Making .sh files executable..."
for file in "$TARGET_DIR"/*.sh; do
    if [[ -f "$file" ]]; then
        chmod a+x "$file"
        echo "Made executable: $file"
    fi
done

echo "Process completed."
