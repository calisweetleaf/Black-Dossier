#!/bin/bash

# Batch update documentation formatting and metadata

echo "Updating all documentation files..."

find ./content ./docs ./internal_drafts -type f -name "*.md" -o -name "*.txt" | while read file; do
  echo "Updating: $file"
  # Example placeholder: Add a last-updated timestamp at end of each file (optional)
  echo "\n\n_Last updated: $(date '+%Y-%m-%d')_" >> "$file"
done

echo "All documents updated successfully."