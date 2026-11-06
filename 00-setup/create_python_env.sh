#!/bin/bash


# Define variables for environment name and Python script
SCRIPT_DIR=$(dirname "$(realpath "$0")")         # Absolute path to this script's directory (00-setup)
PARENT_DIR=$(realpath "$SCRIPT_DIR/..")          # Parent directory where virtual environment will be created
ENV_NAME="$PARENT_DIR/venv"                      # Virtual environment will be created in the parent directory
REQUIREMENTS_FILE="$SCRIPT_DIR/requirements.txt" # requirements.txt is in the 00-setup directory


# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is not installed. Please install Python 3 and try again."
    exit 1
fi

# Check to see if python3-venv is installed
REQUIRED_PACKAGE="python3-venv"

echo "Checking if $REQUIRED_PACKAGE is installed..."
if check_package $REQUIRED_PACKAGE; then
    echo "$REQUIRED_PACKAGE is already installed."
else
    echo "$REQUIRED_PACKAGE is not installed. Installing..."
    sudo apt-get update
    sudo apt-get install -y $REQUIRED_PACKAGE
    if [ $? -ne 0 ]; then
        echo "Error: Failed to install $REQUIRED_PACKAGE. Exiting."
        exit 1
    fi
fi


# Create virtual environment in the parent directory
echo "Creating virtual environment in $PARENT_DIR..."
python3 -m venv $ENV_NAME

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

# Install dependencies from requirements.txt
if [[ -f "$REQUIREMENTS_FILE" ]]; then
    echo "Installing packages from $REQUIREMENTS_FILE..."
    pip install --upgrade pip
    pip install -r $REQUIREMENTS_FILE
else
    echo "Warning: $REQUIREMENTS_FILE not found. No packages will be installed."
fi

# Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

echo "Process completed."
exit 0
