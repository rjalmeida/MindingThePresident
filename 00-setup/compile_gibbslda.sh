#!/bin/bash

# Define paths for directories and files
SCRIPT_DIR=$(dirname "$(realpath "$0")")      # Absolute path to this script's directory (00-setup)
SIBLING_DIR="$SCRIPT_DIR/../LDA"              # Absolute path to sibling directory (01-construction_prevalence_measures)
CPP_SOURCE="$SIBLING_DIR/GibbsLDA.cpp"        # Path to GibbsLDA.cpp in sibling directory (01-construction_prevalence_measures)
OUTPUT_BINARY="$SIBLING_DIR/GibbsLDA.out"     # Output binary file path

# Define the required package
REQUIRED_PACKAGE="libboost-all-dev"

# Function to check if a package is installed
check_package() {
    dpkg -l | grep -qw $1
}

# Check if libboost-all-dev is installed
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

# Check if the C++ source file exists in the sibling directory
if [[ ! -f "$CPP_SOURCE" ]]; then
    echo "Error: Source file $CPP_SOURCE not found in sibling directory (01-LDA)."
    exit 1
fi

# Compile the C++ source file using g++
echo "Compiling $CPP_SOURCE with g++..."
g++ -std=c++17 -o "$OUTPUT_BINARY" "$CPP_SOURCE" -lboost_system -lboost_filesystem

# Check if the compilation was successful
if [[ $? -eq 0 ]]; then
    echo "Compilation successful. Output file: $OUTPUT_BINARY"
else
    echo "Error: Compilation failed."
    exit 1
fi

echo "Script completed successfully."
exit 0
