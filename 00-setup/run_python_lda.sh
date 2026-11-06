#!/bin/bash

# Define variables for environment name and Python script
SCRIPT_DIR=$(dirname "$(realpath "$0")")                                                        # Absolute path to this script's directory (00-setup)
PARENT_DIR=$(realpath "$SCRIPT_DIR/..")                                                         # Parent directory where virtual environment is located
ENV_NAME="$PARENT_DIR/venv"                                                                     # Virtual environment
PYTHON_SCRIPTS=("$PYTHON_CODE_DIR/RunLDA.py" "$PYTHON_CODE_DIR/CalculateTopicPrevalences.py")   # List of Python scripts to run

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

# Function to run a Python script
run_python_script() {
    local script=$1

    # Check if the Python script file exists
    if [[ -f "$script" ]]; then
        echo "Running $script..."
        python3 "$script"
        if [[ $? -eq 0 ]]; then
            echo "$script ran successfully."
        else
            echo "Error: $script encountered an issue during execution."
        fi
    else
        echo "Error: $script not found. Skipping."
    fi
}

# Iterate over the Python scripts and execute them
for script in "${PYTHON_SCRIPTS[@]}"; do
    run_python_script "$script"
done

# Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

echo "Process completed."
exit 0
