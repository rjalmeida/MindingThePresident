#!/usr/bin/env bash
# Reproduce the econometric analysis (Stage 2) using files in this repository.
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
R_DIR="$ROOT_DIR/02-analysis_prevalence_measures/RCodes"
MATLAB_DIR="$ROOT_DIR/02-analysis_prevalence_measures/MatlabCodes"

for program in Rscript matlab; do
    if ! command -v "$program" >/dev/null 2>&1; then
        echo "Error: $program is not available on PATH." >&2
        exit 1
    fi
done

for directory in "$R_DIR" "$MATLAB_DIR"; do
    if [[ ! -d "$directory" ]]; then
        echo "Error: Required directory not found: $directory" >&2
        exit 1
    fi
done

# Git does not store empty directories.
mkdir -p "$R_DIR/output" "$MATLAB_DIR/Output/Figures" "$MATLAB_DIR/Output/Tables"

echo "Running R analysis..."
(
    cd "$R_DIR"
    for script in 0_setup.R GC_analysis.R Correlation_analysis.R; do
        echo "  R: $script"
        Rscript "$script"
    done
)

echo "Running MATLAB analysis..."
(
    cd "$MATLAB_DIR"
    for script in IRs_Analysis.m Predict_Analysis.m Plot_pValues_GC.m; do
        echo "  MATLAB: $script"
        matlab -batch "run('$script')"
    done
)

echo "Stage 2 econometric replication completed successfully."
