Github_Political_organizing/
├── .github/                                  # (GitHub automation, templates, workflows)
│   ├── ISSUE_TEMPLATE/                       # (Community issue templates)
│   │   ├── bug_report.md
│   │   └── feature_request.md
│   └── workflows/                            # (CI/CD actions and automation)
│       ├── publish.yml
│       └── sync_chatgpt.yml
│
├── content/                                  # (Core content: manifestos, guides, organizing tools)
│   ├── Viva La Revolution/                   # (Main revolutionary document and front matter)
│   │   ├── Viva La Revolution - Final Version.md  # (Final, ready-for-publish body)
│   │   ├── Preface_and_Intent.md             # (Preface, Note on Intent, License, Contact)
│   │   └── LICENSE.md                        # (Optional local copy of license for document context)
│   ├── Journalism and Investigative Field Guide.md
│   ├── Investigative Journal Setup.md
│   ├── Journal Workflow.md
│   ├── Journalism ToolKit.md
│   ├── Tools for Political Activism and Journalism.md
│   ├── Grassroots Organizing Template.md
│
├── docs/                                     # (Documentation, internal guides, system design)
│   ├── ai_processing_guidelines.md
│   ├── ai_processing_checklist.md
│   ├── style_guide.md
│   ├── optimized_instructions.md
│   ├── citation_references.md
│   ├── document_cross_reference.md
│   ├── final_document_structure.md
│   ├── osint_tool_database.md
│   ├── verified_citation_database.json
│   ├── tasks.md
│   ├── changelog.md
│   ├── feedback_log.md
│   └── reference_links.md
│
├── maintenance/                              # (Meta-project logs, structure, verification)
│   ├── project_verification.log
│   ├── project_structure.txt
│   └── Project File Tree.md                  # (Annotated tree — to be generated/updated regularly)
│
├── publishing/                               # (Publishing tools and templates)
│   ├── mla_template.tex
│   ├── convert_to_pdf.sh                     # (PDF automation for Unix)
│   └── convert_to_pdf.bat                    # (PDF automation for Windows)
│
├── scripts/                                  # (Automation scripts and tools)
│   ├── batch_process_files.sh                # (Batch file processor)
│   ├── sync_github.sh                        # (GitHub sync automation)
│   ├── update_docs.sh                        # (Documentation update helper)
│   ├── generate_pdf.sh                       # (One-command PDF generation)
│   └── verify_project_integrity.py           # (Check project structure and files)
│
├── releases/                                 # (Final public release versions, zips, PDFs) — NEW
│   └── [Placeholder for final releases]      # (To be added: Viva La Revolution - Public.pdf, etc.)
│
├── internal_drafts/                          # (Unpublished drafts, in-progress work) — NEW
│   └── [Placeholder for internal working drafts]
│
├── README.MD                                 # (Main overview of the project and license reference)
├── optimized_instructions.md                 # (For AI, human operators — duplicate for quick ref)
├── changelog.md                              # (Global changelog - mirrors docs/changelog.md)
├── feedback_log.md                           # (Global feedback log - mirrors docs/feedback_log.md)
├── reference_links.md                        # (Global references - mirrors docs/reference_links.md)
├── verification_report.log                   # (Last run verification report)
├── .GITIGNORE                                # (Git ignore list)
└── LICENSE                                   # (Root license — applies to whole project)
