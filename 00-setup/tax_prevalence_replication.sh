#!/bin/bash

# Define the names of the scripts to run
SCRIPTS=(
    "check_software.sh"
    "create_python_env.sh"
    "compile_gibbslda.sh"
    "run_python_lda.sh"
)

# Function to run each script
run_script() {
    local script=$1
    if [[ -f "$script" ]]; then
        echo "Running $script..."
        ./"$script"
        if [[ $? -eq 0 ]]; then
            echo "$script completed successfully."
        else
            echo "Error: $script encountered an issue during execution."
        fi
    else
        echo "Error: $script not found. Skipping."
    fi
}

# Run each script in sequence
for script in "${SCRIPTS[@]}"; do
    run_script "$script"
done

echo "All scripts have been processed."
exit 0
