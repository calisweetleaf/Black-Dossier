#!/bin/bash
# Markdown-to-PDF Conversion Script (Linux/macOS)
# Converts all .md files in the current directory to PDFs using MLA-style formatting

TEX_TEMPLATE="mla_template.tex"
PDF_ENGINE="xelatex"  # Ensures proper font rendering
OUTPUT_DIR="output_pdfs"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

# Convert all Markdown files to PDFs
for file in *.md; do
    filename=$(basename "$file" .md)
    pandoc "$file" --template="$TEX_TEMPLATE" --pdf-engine="$PDF_ENGINE" -o "$OUTPUT_DIR/$filename.pdf"
    echo "Converted $file → $OUTPUT_DIR/$filename.pdf"
done

echo "✅ All Markdown files have been converted to MLA-styled PDFs!"