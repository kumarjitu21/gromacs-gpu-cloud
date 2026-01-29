#!/bin/bash
set -e  # Stop on error

# Disable GPU compatibility check (useful for compatibility issues)
export GMX_GPU_DISABLE_COMPATIBILITY_CHECK=1

# Run MD simulation with GPU acceleration
# -deffnm MD: uses MD.tpr, MD.gro, MD.mdp files
# -nb gpu: use GPU for non-bonded interactions
# -v: verbose output
gmx mdrun -deffnm MD -nb gpu -v
