#!/bin/bash

# Define variables for environment name and R scripts
SCRIPT_DIR=$(dirname "$(realpath "$0")")                           # Absolute path to this script's directory (00-setup)
PARENT_DIR=$(realpath "$SCRIPT_DIR/..")                            # Parent directory where virtual environment will be created
R_CODE_DIR="$PARENT_DIR/02-analysis_prevalence_measures/RCodes"    # Directory containing R code
R_SCRIPTS=("0_setup.R" "GC_analysis.R" "Correlation_analysis.R")   # List of R scripts to run


# Change to the R code directory
if [[ -d "$R_CODE_DIR" ]]; then
    cd "$R_CODE_DIR" || { echo "Error: Failed to change directory to $R_CODE_DIR"; exit 1; }
    echo "Changed directory to $R_CODE_DIR."
else
    echo "Error: Directory $R_CODE_DIR does not exist."
    exit 1
fi

# Function to run an R script
run_r_script() {
    local script=$1
    if [[ -f "$script" ]]; then
        echo "Running $script..."
        Rscript "$script"
        if [[ $? -eq 0 ]]; then
            echo "$script ran successfully."
        else
            echo "Error: $script encountered an issue during execution."
        fi
    else
        echo "Error: $script not found. Skipping."
    fi
}

# Iterate over the R scripts and execute them
for script in "${R_SCRIPTS[@]}"; do
    run_r_script "$script"
done

echo "All specified R scripts have been processed."

exit 0
