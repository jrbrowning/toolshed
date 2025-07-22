#!/bin/bash

##############################################################################
# py_cache_clean.sh
#
# Build Motivation / Defensive Scripting Rationale
#
#   - Deletion is NEVER triggered by a flag like --delete or --force.
#   - You MUST manually confirm via keyboard (y/N) before anything is deleted.
#   - Dry-run is always the default, including in automation or when run by mistake.
#
# Why? Because typing `--delete` or `--force` makes it dangerously easy to up-arrow
# and re-run a destructive command in your shell history, especially on muscle memory.
# This script intentionally excludes those options to avoid "auto-pilot" mistakes.
# Defensive scripting like this is recommended for cleanup tasks in active projects,
# where a wrong keystroke can delete large trees of source files.
#
# -N (no) is always the default answer. Only 'y' or 'Y' will actually delete.
#
# I call this approach to scripting HOD-SCA: Highly Opinionated Defensive SCripting Approach.
##############################################################################

# Usage:
#   ./py_cache_clean.sh [target_dir] [--dry-run]
# If no target_dir: current dir.
# --dry-run disables any delete, always safe for automation.

TARGET_DIR="."
DO_DELETE=0

for arg in "$@"; do
    if [[ "$arg" == "--dry-run" ]]; then
        DO_DELETE=0
    else
        TARGET_DIR="$arg"
    fi
done

echo "Searching in: $TARGET_DIR"
echo
echo "Would remove the following .pyc files:"
find "$TARGET_DIR" -type f -name '*.pyc' 2>/dev/null
echo
echo "Would remove the following __pycache__ directories:"
find "$TARGET_DIR" -type d -name '__pycache__' 2>/dev/null
echo

if [[ "$1" == "--dry-run" || "$2" == "--dry-run" ]]; then
    echo "DRY RUN ONLY. No files or directories were deleted."
    exit 0
fi

read -p "Do you want to PERMANENTLY DELETE these files and directories? (y/N): " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo "Deleting .pyc files..."
find "$TARGET_DIR" -type f -name '*.pyc' -delete 2>/dev/null

echo "Deleting __pycache__ directories..."
find "$TARGET_DIR" -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null

echo "Cleanup complete."