#!/bin/bash

# Function to check if a program is installed
check_program() {
  local check_command=$1
  local display_name=$2

  if ! command -v $check_command &> /dev/null; then
    echo "Error: $display_name is not installed."
    exit 1
  else
    echo "$display_name is installed."
  fi
}

# Check for Python
check_program "python3" "Python"

# Check for R
check_program "R" "R"

# Check for MATLAB
check_program "matlab" "MATLAB"

echo "All required software is installed."
exit 0
