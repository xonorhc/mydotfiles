#!/bin/bash

SPRINT_START="2026-05-28"
SPRINT_END="2026-06-15"
OUTPUT_DIR="reports"

mkdir -p $OUTPUT_DIR

echo "Generating Sprint Report..."

# Commit report (CSV)
git log --since="$SPRINT_START" --until="$SPRINT_END" \
--pretty=format:"%H,%an,%ad,%s" --date=short > $OUTPUT_DIR/commits.csv

# Contributors summary
git shortlog -s -n --since="$SPRINT_START" --until="$SPRINT_END" \
> $OUTPUT_DIR/contributors.txt

# Detailed changes
git log --since="$SPRINT_START" --until="$SPRINT_END" --stat \
> $OUTPUT_DIR/changes.txt

echo "Report saved in $OUTPUT_DIR"
