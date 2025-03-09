import os
import hashlib
import argparse
import logging

# Expected file structure and paths
expected_structure = {
    "content": [
        "Journalism_and_Investigative_Field_Guide.md",
        "Investigative_Journal_Setup.md",
        "Journal_Workflow.md",
        "Journalism_ToolKit.md",
        "Tools_for_Political_Activism_and_Journalism.md",
        "Grassroots_Organizing_Template.md",
        "Vįva_Łą_Řɛvölutîön.md",
    ],
    "docs": [
        "README.md",
        "optimized_instructions.md",
        "ai_processing_guidelines.md",
        "style_guide.md",
        "changelog.md",
        "feedback_log.md",
        "tasks.md",
        "reference_links.md",
        "citation_references.md",
        "document_cross_reference.md",
        "ai_processing_checklist.md",
        "final_document_structure.md",
        "osint_tool_database.md",
        "verified_citation_database.json",
    ],
    "publishing": [
        "mla_template.tex",
        "convert_to_pdf.sh",
        "convert_to_pdf.bat",
    ],
    "scripts": [
        "batch_process_files.sh",
        "sync_github.sh",
        "update_docs.sh",
        "generate_pdf.sh",
    ],
    ".github/ISSUE_TEMPLATE": [
        "bug_report.md",
        "feature_request.md",
    ],
    ".github/workflows": [
        "publish.yml",
        "sync_chatgpt.yml",
    ],
}

# Setup logging
logging.basicConfig(
    filename="project_verification.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

def verify_files(base_dir):
    """Recursively check all expected files and detect missing or misplaced files."""
    missing_files = []
    found_files = set()

    logging.info("Starting recursive file verification...")
    print("\n🔍 Scanning directories...\n")

    # Walk through all folders & collect actual files found
    for root, _, files in os.walk(base_dir):
        for file in files:
            relative_path = os.path.relpath(os.path.join(root, file), base_dir)
            found_files.add(relative_path)

    # Check if all expected files exist in their correct folders
    for folder, files in expected_structure.items():
        for file_name in files:
            expected_path = os.path.join(folder, file_name)

            if expected_path not in found_files:
                logging.warning(f"Missing or misplaced: {expected_path}")
                print(f"[❌] Missing: {expected_path}")
                missing_files.append(expected_path)

    if not missing_files:
        print("\n✅ All files are correctly placed. No data loss detected.")
        logging.info("All files verified successfully.")
    else:
        print("\n⚠ Verification completed with missing files detected.")
        print(f"❌ Total missing files: {len(missing_files)} (Check log for details)")
        logging.warning(f"Total missing files: {len(missing_files)}")

    print("\n📜 Full verification log saved to: project_verification.log")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Recursively verify project file integrity.")
    parser.add_argument("--path", type=str, required=True, help="Path to the extracted project folder")
    args = parser.parse_args()

    if not os.path.exists(args.path):
        print(f"❌ Error: The specified path '{args.path}' does not exist.")
        exit(1)

    verify_files(args.path)