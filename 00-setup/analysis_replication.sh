#!/usr/bin/env bash
# Reproduce the econometric analysis (Stage 2) using files in this repository.
set -euo pipefail

usage() {
    cat <<'USAGE'
Usage: analysis_replication.sh [--install | --no-install | --help]

  --install     Install R dependencies, then run the R and MATLAB analyses.
  --no-install  Run the analyses without installing dependencies (default).
  --help        Show this help message.
USAGE
}

if (( $# > 1 )); then
    echo "Error: Expected at most one option." >&2
    usage >&2
    exit 2
fi

INSTALL=false
case "${1:-}" in
    --install)
        INSTALL=true
        ;;
    --no-install|"")
        ;;
    --help|-h)
        usage
        exit 0
        ;;
    *)
        echo "Error: Unknown option: $1" >&2
        usage >&2
        exit 2
        ;;
esac

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

(
    cd "$R_DIR"

    if [[ "$INSTALL" == true ]]; then
        echo "Installing R dependencies..."
        Rscript 0_setup.R
    fi

    echo "Running R analysis..."
    for script in GC_analysis.R Correlation_analysis.R; do
        echo "  R: $script"
        Rscript "$script"
    done
)

echo "Running MATLAB analysis..."
(
    cd "$MATLAB_DIR"
    # Use one MATLAB session: Predict_Analysis.m uses results from IRs_Analysis.m.
    matlab -batch "run('IRs_Analysis.m'); run('Predict_Analysis.m'); run('Plot_pValues_GC.m')"
)

echo "Stage 2 econometric replication completed successfully."