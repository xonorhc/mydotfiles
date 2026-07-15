#!/bin/bash

echo "Generating Git Report..."

git log --since="30 days ago" \
--pretty=format:"%H,%an,%ad,%s" \
--date=short > commits.csv

git shortlog -s -n > contributors.txt

git log --stat > changes.txt

echo "Report generated successfully."
