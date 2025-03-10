#!/bin/bash

# batch_process_files.sh
# Master script to reorganize files and verify integrity

set -e # Exit on error

# Configuration
SOURCE_DIR="Z:/Unsorted_Files"
DEST_DIR="Z:/OutputDirectory/Political_Activism_Project"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_CMD="python" # Change to "python3" if needed for your environment

# ANSI color codes for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to display usage information
show_help() {
    echo -e "${BLUE}Political Activism Project - Batch Processing Tool${NC}"
    echo
    echo "Usage: $(basename "$0") [options]"
    echo
    echo "Options:"
    echo "  -s, --source DIR       Set source directory (default: $SOURCE_DIR)"
    echo "  -d, --dest DIR         Set destination directory (default: $DEST_DIR)"
    echo "  -b, --backup           Create backup before processing"
    echo "  -c, --create-missing   Create blank templates for missing files"
    echo "  -n, --dry-run          Show what would be done without making changes"
    echo "  -v, --verify-only      Only run verification without reorganizing"
    echo "  -p, --pdf              Generate PDFs after processing"
    echo "  -g, --github           Sync with GitHub repository after processing"
    echo "  -h, --help             Show this help message"
    echo
}

# Parse command line arguments
BACKUP=false
CREATE_MISSING=false
DRY_RUN=false
VERIFY_ONLY=false
GENERATE_PDF=false
SYNC_GITHUB=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -s|--source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        -d|--dest)
            DEST_DIR="$2"
            shift 2
            ;;
        -b|--backup)
            BACKUP=true
            shift
            ;;
        -c|--create-missing)
            CREATE_MISSING=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -v|--verify-only)
            VERIFY_ONLY=true
            shift
            ;;
        -p|--pdf)
            GENERATE_PDF=true
            shift
            ;;
        -g|--github)
            SYNC_GITHUB=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check if directories exist
if [ ! -d "$SOURCE_DIR" ]; then
    echo -e "${RED}Error: Source directory does not exist: $SOURCE_DIR${NC}"
    exit 1
fi

# Create log directory
LOG_DIR="$SCRIPT_DIR/logs"
mkdir -p "$LOG_DIR"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOG_DIR/batch_process_$TIMESTAMP.log"

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

log "INFO" "Starting batch processing"
log "INFO" "Source: $SOURCE_DIR"
log "INFO" "Destination: $DEST_DIR"
log "INFO" "Log file: $LOG_FILE"

# Check Python availability
if ! command -v $PYTHON_CMD &> /dev/null; then
    log "ERROR" "Python is not available. Please install Python or adjust PYTHON_CMD variable."
    exit 1
fi

# Build command options
REORGANIZE_OPTIONS=""
if [ "$BACKUP" = true ]; then
    REORGANIZE_OPTIONS="$REORGANIZE_OPTIONS --backup"
    log "INFO" "Backup will be created before processing"
fi

if [ "$CREATE_MISSING" = true ]; then
    REORGANIZE_OPTIONS="$REORGANIZE_OPTIONS --create-missing"
    log "INFO" "Missing files will be created as blank templates"
fi

if [ "$DRY_RUN" = true ]; then
    REORGANIZE_OPTIONS="$REORGANIZE_OPTIONS --dry-run"
    log "INFO" "Dry run mode - no changes will be made"
fi

# Step 1: Reorganize files (unless verify-only mode is active)
if [ "$VERIFY_ONLY" = false ]; then
    log "INFO" "Reorganizing files..."
    REORGANIZE_CMD="$PYTHON_CMD $SCRIPT_DIR/reorganize_files.py --source \"$SOURCE_DIR\" --dest \"$DEST_DIR\" $REORGANIZE_OPTIONS"
    
    log "INFO" "Running: $REORGANIZE_CMD"
    if eval $REORGANIZE_CMD; then
        log "SUCCESS" "File reorganization completed successfully"
    else
        log "ERROR" "File reorganization failed with exit code $?"
        exit 1
    fi
else
    log "INFO" "Skipping reorganization (verify-only mode)"
fi

# Step 2: Verify project integrity
log "INFO" "Verifying project integrity..."
VERIFY_CMD="$PYTHON_CMD $SCRIPT_DIR/verify_project_integrity.py"

log "INFO" "Running: $VERIFY_CMD"
if eval $VERIFY_CMD; then
    log "SUCCESS" "Verification completed successfully"
else
    log "WARNING" "Verification completed with warnings or errors"
fi

# Step 3: Generate PDFs if requested
if [ "$GENERATE_PDF" = true ]; then
    log "INFO" "Generating PDFs..."
    if [ -f "$SCRIPT_DIR/generate_pdf.sh" ]; then
        if bash "$SCRIPT_DIR/generate_pdf.sh" "$DEST_DIR"; then
            log "SUCCESS" "PDF generation completed successfully"
        else
            log "ERROR" "PDF generation failed with exit code $?"
        fi
    else
        log "ERROR" "generate_pdf.sh script not found"
    fi
fi

# Step 4: Sync with GitHub if requested
if [ "$SYNC_GITHUB" = true ]; then
    log "INFO" "Syncing with GitHub..."
    if [ -f "$SCRIPT_DIR/sync_github.sh" ]; then
        if bash "$SCRIPT_DIR/sync_github.sh" "$DEST_DIR"; then
            log "SUCCESS" "GitHub sync completed successfully"
        else
            log "ERROR" "GitHub sync failed with exit code $?"
        fi
    else
        log "ERROR" "sync_github.sh script not found"
    fi
fi

# Step 5: Update documentation if needed
if [ "$VERIFY_ONLY" = false ] && [ "$DRY_RUN" = false ]; then
    log "INFO" "Updating documentation..."
    if [ -f "$SCRIPT_DIR/update_docs.sh" ]; then
        if bash "$SCRIPT_DIR/update_docs.sh" "$DEST_DIR"; then
            log "SUCCESS" "Documentation update completed successfully"
        else
            log "WARNING" "Documentation update completed with warnings"
        fi
    else
        log "WARNING" "update_docs.sh script not found, skipping documentation update"
    fi
fi

log "SUCCESS" "Batch processing completed"
echo -e "${GREEN}===========================================================${NC}"
echo -e "${GREEN}Batch processing completed successfully${NC}"
echo -e "${BLUE}Log file: $LOG_FILE${NC}"
echo -e "${GREEN}===========================================================${NC}"
