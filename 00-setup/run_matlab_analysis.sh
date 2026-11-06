#!/bin/bash

# Define variables for environment name and R scripts
SCRIPT_DIR=$(dirname "$(realpath "$0")")                                          # Absolute path to this script's directory (00-setup)
PARENT_DIR=$(realpath "$SCRIPT_DIR/..")                                           # Parent directory where virtual environment will be created
MATLAB_CODE_DIR="$PARENT_DIR/02-analysis_prevalence_measures/MatlabCodes"         # Directory containing R code
MATLAB_SCRIPTS=("$MATLAB_CODE_DIR/IRs_Analysis" "$MATLAB_CODE_DIR/Predict_Analysis" "$MATLAB_CODE_DIR/Plot_pValues_GC")   # List of MATLAB scripts to run

# Change to the Matlab code directory
if [[ -d "$MATLAB_CODE_DIR" ]]; then
    cd "$MATLAB_CODE_DIR" || { echo "Error: Failed to change directory to $MATLAB_CODE_DIR"; exit 1; }
    echo "Changed directory to $MATLAB_CODE_DIR."
else
    echo "Error: Directory $MATLAB_CODE_DIR does not exist."
    exit 1
fi

# MATLAB command options
MATLAB_CMD="matlab -nodisplay -nodesktop -r"

# Function to run a MATLAB script using batch
run_matlab_script() {
    local script=$1
    local script_file="${script}.m"
    
    # Check if the MATLAB script file exists
    if [[ -f "$script_file" ]]; then
        echo "Running $script_file..."
        $MATLAB_CMD "try, run('$script_file'), catch, exit(1), end, exit(0);"
        if [[ $? -eq 0 ]]; then
            echo "$script_file ran successfully."
        else
            echo "Error: $script_file encountered an issue during execution."
        fi
    else
        echo "Error: $script_file not found. Skipping."
    fi
}


# Iterate over the MATLAB scripts and execute them in batch
for script in "${MATLAB_SCRIPTS[@]}"; do
    run_matlab_script "$script"
done

exit 0
