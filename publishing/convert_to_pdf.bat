@echo off
REM Markdown-to-PDF Conversion Script (Windows)
REM Converts all .md files in the current directory to PDFs using MLA-style formatting

SET TEX_TEMPLATE=mla_template.tex
SET OUTPUT_DIR=output_pdfs

REM Ensure output directory exists
IF NOT EXIST "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Convert all Markdown files to PDFs
FOR %%F IN (*.md) DO (
    SETLOCAL ENABLEDELAYEDEXPANSION
    SET "FILENAME=%%~nF"
    pandoc "%%F" --template="%TEX_TEMPLATE%" --pdf-engine=xelatex -o "%OUTPUT_DIR%\!FILENAME!.pdf"
    echo Converted %%F → %OUTPUT_DIR%\!FILENAME!.pdf
    ENDLOCAL
)

echo ✅ All Markdown files have been converted to MLA-styled PDFs!
pause