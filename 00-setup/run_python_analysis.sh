#!/bin/bash

# Define variables for environment name and Python script
SCRIPT_DIR=$(dirname "$(realpath "$0")")                                # Absolute path to this script's directory (00-setup)
PARENT_DIR=$(realpath "$SCRIPT_DIR/..")                                 # Parent directory where virtual environment is located
ENV_NAME="$PARENT_DIR/venv"                                             # Virtual environment
PYTHON_CODE_DIR="$PARENT_DIR/01-construction_prevalence_measures"       # Directory containing Python code
MAIN_SCRIPT="$PYTHON_CODE_DIR/PrepareGraphs.py"                         # script is in the Python directory


# Activate virtual environment
echo "Activating virtual environment..."
source $ENV_NAME/bin/activate

# Check if activation was successful
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "Virtual environment activated."
else
    echo "Error: Failed to activate the virtual environment."
    exit 1
fi

# Run the main Python script
if [[ -f "$MAIN_SCRIPT" ]]; then
    echo "Running $MAIN_SCRIPT..."
    python $MAIN_SCRIPT
else
    echo "Error: $MAIN_SCRIPT not found. Please ensure the script is present in the current directory."
    deactivate
    exit 1
fi

# Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

echo "Process completed."
exit 0
