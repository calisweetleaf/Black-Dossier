import os
import hashlib
import logging

# Configuration
SOURCE_DIR = r"Z:\Unsorted_Files"
DEST_DIR = r"Z:\OutputDirectory\Political_Activism_Project"
LOG_FILE = "verification_report.log"

# Folder structure mapping (must match your reorganization script)
FOLDER_STRUCTURE = {
    ".": ["README.MD"],
    "content": [
        "Journalism and Investigative Field Guide.md",
        "Investigative Journal Setup.md",
        "Journal Workflow.md",
        "Journalism ToolKit.md",
        "Tools for Political Activism and Journalism.md",
        "Grassroots Organizing Template.md",
        "Vįva Łą Řɛvölutîön.md",
    ],
    "docs": [
        "optimized_instructions.md",
        "changelog.md",
        "feedback_log.md",
        "tasks.md",
        "reference_links.md",
    ],
    "publishing": [
        "mla_template.tex",
        "convert_to_pdf.bat",
        "convert_to_pdf.sh",
    ],
}

# Setup logging
logging.basicConfig(
    filename=LOG_FILE,
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
    filemode='w'  # Overwrite previous log
)

def normalize_name(name):
    """Case-insensitive normalization with space/underscore handling"""
    return name.lower().replace(" ", "_").replace(".md", "").strip("_")

def file_hash(filepath):
    """Calculate SHA-256 hash of a file"""
    sha = hashlib.sha256()
    with open(filepath, 'rb') as f:
        while True:
            data = f.read(65536)
            if not data:
                break
            sha.update(data)
    return sha.hexdigest()

def verify_files():
    total_files = 0
    verified = 0
    missing_source = 0
    missing_dest = 0
    mismatches = 0

    logging.info("Starting verification process...")
    print("🔍 Starting file verification...\n")

    # Check files that should have been moved
    for folder, files in FOLDER_STRUCTURE.items():
        for filename in files:
            total_files += 1
            dest_path = os.path.join(DEST_DIR, folder, filename)
            source_path = os.path.join(SOURCE_DIR, filename)

            # Find source file with flexible matching
            found_source = None
            for f in os.listdir(SOURCE_DIR):
                if normalize_name(f) == normalize_name(filename):
                    found_source = os.path.join(SOURCE_DIR, f)
                    break

            if not found_source:
                missing_source += 1
                msg = f"Missing in source: {filename} (expected in {folder})"
                logging.error(msg)
                print(f"❌ {msg}")
                continue

            if not os.path.exists(dest_path):
                missing_dest += 1
                msg = f"Missing in destination: {filename} (should be in {folder})"
                logging.error(msg)
                print(f"❌ {msg}")
                continue

            # Compare file contents
            try:
                source_hash = file_hash(found_source)
                dest_hash = file_hash(dest_path)
                
                if source_hash != dest_hash:
                    mismatches += 1
                    msg = f"Content mismatch: {filename} in {folder}"
                    logging.error(msg)
                    print(f"❌ {msg}")
                else:
                    verified += 1
                    logging.info(f"Verified: {filename} in {folder}")
                    print(f"✅ Verified: {filename}")

            except Exception as e:
                logging.error(f"Error verifying {filename}: {str(e)}")
                print(f"⚠️ Error checking {filename}: {str(e)}")

    # Check for leftover files in destination (potential blank templates)
    blank_files = 0
    for root, dirs, files in os.walk(DEST_DIR):
        for file in files:
            file_path = os.path.join(root, file)
            relative_path = os.path.relpath(file_path, DEST_DIR)
            
            # Check if file is accounted for in structure
            accounted = False
            for folder, fnames in FOLDER_STRUCTURE.items():
                if relative_path in [os.path.join(folder, f) for f in fnames]:
                    accounted = True
                    break
            
            if not accounted:
                blank_files += 1
                msg = f"Unexpected file: {relative_path} (potential blank template)"
                logging.warning(msg)
                print(f"⚠️ {msg}")

    # Generate summary
    summary = f"""
    Verification Complete:
    ----------------------
    Total files checked: {total_files}
    Successfully verified: {verified}
    Missing in source: {missing_source}
    Missing in destination: {missing_dest}
    Content mismatches: {mismatches}
    Potential blank templates: {blank_files}
    
    Full log available at: {LOG_FILE}
    """

    logging.info(summary)
    print(summary)

if __name__ == "__main__":
    verify_files()