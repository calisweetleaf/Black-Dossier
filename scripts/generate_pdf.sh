#!/bin/bash

# generate_pdf.sh
# Script to convert markdown files to PDF format

set -e # Exit on error

# Configuration
PROJECT_DIR=${1:-"Z:/OutputDirectory/Political_Activism_Project"}
OUTPUT_DIR="$PROJECT_DIR/output/pdf"
TEMPLATE_FILE="$PROJECT_DIR/publishing/mla_template.tex"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/logs"

# ANSI color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create log directory and file
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/pdf_generation_$TIMESTAMP.log"

# Function to log messages
log() {
    local level="$1"
    local message="$2"
    local color="$NC"
    
    case "$level" in
        "INFO") color="$BLUE" ;;
        "SUCCESS") color="$GREEN" ;;
        "WARNING") color="$YELLOW" ;;
        "ERROR") color="$RED" ;;
    esac
    
    echo -e "${color}[$level] $message${NC}"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $level - $message" >> "$LOG_FILE"
}

log "INFO" "Starting PDF generation"
log "INFO" "Project directory: $PROJECT_DIR"
log "INFO" "Output directory: $OUTPUT_DIR"

# Check if pandoc is installed
if ! command -v pandoc &> /dev/null; then
    log "ERROR" "pandoc is not installed. Please install pandoc to generate PDFs."
    exit 1
fi

# Check if project directory exists
if [ ! -d "$PROJECT_DIR" ]; then
    log "ERROR" "Project directory does not exist: $PROJECT_DIR"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"
log "INFO" "Created output directory: $OUTPUT_DIR"

# Generate metadata file for PDF generation
METADATA_FILE="$OUTPUT_DIR/metadata.yaml"
cat > "$METADATA_FILE" << EOF
---
title: "Political Activism Project"
author: "Project Collaborators"
date: "$(date +"%B %d, %Y")"
geometry: margin=1in
fontsize: 12pt
documentclass: article
header-includes:
  - \usepackage{fancyhdr}
  - \pagestyle{fancy}
  - \fancyhead[R]{Political Activism Project}
  - \fancyfoot[C]{\thepage}
---
EOF

log "INFO" "Created metadata file: $METADATA_FILE"

# Function to convert a single markdown file to PDF
convert_to_pdf() {
    local input_file="$1"
    local relative_path="${input_file#$PROJECT_DIR/}"
    local file_name=$(basename "$input_file" .md)
    local output_file="$OUTPUT_DIR/${file_name}.pdf"
    
    log "INFO" "Converting $relative_path to PDF"
    
    # Check if template exists
    local template_option=""
    if [ -f "$TEMPLATE_FILE" ]; then
        template_option="--template=$TEMPLATE_FILE"
    fi
    
    # Convert markdown to PDF
    if pandoc "$input_file" -o "$output_file" \
        --from markdown \
        --to pdf \
        $template_option \
        --metadata-file="$METADATA_FILE" \
        --pdf-engine=xelatex \
        --standalone; then
        
        log "SUCCESS" "Generated PDF: $output_file"
        return 0
    else
        log "ERROR" "Failed to generate PDF for $relative_path"
        return 1
    fi
}

# Function to process a directory recursively
process_directory() {
    local dir="$1"
    local files_found=0
    local files_converted=0
    local files_failed=0
    
    # Process markdown files in the current directory
    for file in "$dir"/*.md; do
        if [ -f "$file" ]; then
            files_found=$((files_found + 1))
            if convert_to_pdf "$file"; then
                files_converted=$((files_converted + 1))
            else
                files_failed=$((files_failed + 1))
            fi
        fi
    done
    
    # Process subdirectories
    for subdir in "$dir"/*; do
        if [ -d "$subdir" ] && [ "$(basename "$subdir")" != "output" ]; then
            local subdir_results=$(process_directory "$subdir")
            local subdir_found=$(echo "$subdir_results" | cut -d'|' -f1)
            local subdir_converted=$(echo "$subdir_results" | cut -d'|' -f2)
            local subdir_failed=$(echo "$subdir_results" | cut -d'|' -f3)
            
            files_found=$((files_found + subdir_found))
            files_converted=$((files_converted + subdir_converted))
            files_failed=$((files_failed + subdir_failed))
        fi
    done
    
    # Return results
    echo "$files_found|$files_converted|$files_failed"
}

# Process all markdown files in the project
log "INFO" "Scanning for markdown files in $PROJECT_DIR"
results=$(process_directory "$PROJECT_DIR")
files_found=$(echo "$results" | cut -d'|' -f1)
files_converted=$(echo "$results" | cut -d'|' -f2)
files_failed=$(echo "$results" | cut -d'|' -f3)

# Create an index PDF with links to all generated PDFs
INDEX_MD="$OUTPUT_DIR/index.md"
cat > "$INDEX_MD" << EOF
# Political Activism Project - Document Index

Generated on $(date +"%B %d, %Y at %H:%M:%S")

## Available Documents

EOF

for pdf_file in "$OUTPUT_DIR"/*.pdf; do
    if [ -f "$pdf_file" ] && [ "$(basename "$pdf_file")" != "index.pdf" ]; then
        base_name=$(basename "$pdf_file" .pdf)
        echo "* [$base_name]($base_name.pdf)" >> "$INDEX_MD"
    fi
done

log "INFO" "Creating index document"
if pandoc "$INDEX_MD" -o "$OUTPUT_DIR/index.pdf" \
    --from markdown \
    --to pdf \
    --metadata-file="$METADATA_FILE" \
    --pdf-engine=xelatex \
    --standalone; then
    
    log "SUCCESS" "Generated index PDF: $OUTPUT_DIR/index.pdf"
else
    log "ERROR" "Failed to generate index PDF"
fi

# Generate summary report
SUMMARY_REPORT="$OUTPUT_DIR/generation_report.txt"
cat > "$SUMMARY_REPORT" << EOF
PDF Generation Report
====================
Generated on: $(date +"%B %d, %Y at %H:%M:%S")

Summary:
- Total files found: $files_found
- Successfully converted: $files_converted
- Failed to convert: $files_failed

Output directory: $OUTPUT_DIR
Log file: $LOG_FILE

EOF

log "SUCCESS" "PDF generation completed"
log "INFO" "Total files found: $files_found"
log "INFO" "Successfully converted: $files_converted"
log "INFO" "Failed to convert: $files_failed"

echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}PDF Generation Complete${NC}"
echo -e "${BLUE}Files found:     $files_found${NC}"
echo -e "${GREEN}Files converted: $files_converted${NC}"
if [ $files_failed -gt 0 ]; then
    echo -e "${RED}Files failed:    $files_failed${NC}"
else
    echo -e "${GREEN}Files failed:    $files_failed${NC}"
fi
echo -e "${BLUE}Output directory: $OUTPUT_DIR${NC}"
echo -e "${BLUE}Log file: $LOG_FILE${NC}"
echo -e "${GREEN}===========================================================${NC}"

exit 0
