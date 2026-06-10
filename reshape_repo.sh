#!/usr/bin/env bash
# =============================================================================
# reshape_repo.sh
# Reshapes the repository into the new standardised folder structure.
# Run from the ROOT of your git repository.
# Safe to run on a clean working tree (commit or stash changes first).
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Safety check
# ---------------------------------------------------------------------------
if [ ! -d ".git" ]; then
  echo "ERROR: Run this script from the root of your git repository."
  exit 1
fi

echo "==> Reshaping repository structure..."

# ---------------------------------------------------------------------------
# 1. Create all top-level directories
# ---------------------------------------------------------------------------
TOP_LEVEL_DIRS=(
  ".github"
  ".github/ISSUE_TEMPLATE"
  ".github/workflows"
  "example_scripts"
  "notebook_examples"
  "data_examples"
  "docs"
  "examples"
  "ext"
  "src"
  "tests"
)

for d in "${TOP_LEVEL_DIRS[@]}"; do
  mkdir -p "$d"
done

# ---------------------------------------------------------------------------
# 2. Create all docs/ subdirectories
# ---------------------------------------------------------------------------
DOCS_SUBDIRS=(
  "docs/src"
  "docs/01_install"
  "docs/02_quickstart"
  "docs/03_data_augmented_data_sqlitedb"
  "docs/04_preprocessing_showcase"
  "docs/05_dictionary_learning"
  "docs/06_deconvolution"
  "docs/07_network"
  "docs/08_simulations"
  "docs/09_math"
  "docs/10_assets"
)

for d in "${DOCS_SUBDIRS[@]}"; do
  mkdir -p "$d"
done

# ---------------------------------------------------------------------------
# 3. Migrate existing content
# ---------------------------------------------------------------------------

# -- doc/ → docs/ (Sphinx config, markdown docs, assets) -------------------
if [ -d "doc" ]; then
  echo "  Migrating doc/ → docs/ ..."

  # Sphinx build config stays in docs/src
  [ -f "doc/conf.py" ]   && mv "doc/conf.py"   "docs/src/conf.py"
  [ -f "doc/Makefile" ]  && mv "doc/Makefile"  "docs/src/Makefile"
  [ -f "doc/make.bat" ]  && mv "doc/make.bat"  "docs/src/make.bat"
  [ -f "doc/index.rst" ] && mv "doc/index.rst" "docs/src/index.rst"

  # Workflow markdown files → matching numbered subdirs
  [ -f "doc/KEGGREST.md" ] && mv "doc/KEGGREST.md" "docs/02_quickstart/KEGGREST.md"
  [ -f "doc/KOFAM.md" ]    && mv "doc/KOFAM.md"    "docs/02_quickstart/KOFAM.md"
  [ -f "doc/eggNOG.md" ]   && mv "doc/eggNOG.md"   "docs/02_quickstart/eggNOG.md"

  [ -f "doc/FunctionalAnnotationWorkflows.md" ] && \
    mv "doc/FunctionalAnnotationWorkflows.md" \
       "docs/04_preprocessing_showcase/FunctionalAnnotationWorkflows.md"

  [ -f "doc/WhereDoIgetTheGenomesOrTheProteomesOfMicrobialCollectionOfIamInterestedIn.md" ] && \
    mv "doc/WhereDoIgetTheGenomesOrTheProteomesOfMicrobialCollectionOfIamInterestedIn.md" \
       "docs/03_data_augmented_data_sqlitedb/WhereDoIgetTheGenomesOrTheProteomesOfMicrobialCollectionOfIamInterestedIn.md"

  # Images / assets → docs/10_assets
  shopt -s nullglob
  for img in doc/*.png doc/*.jpg doc/*.jpeg doc/*.gif doc/*.svg; do
    mv "$img" "docs/10_assets/"
  done
  shopt -u nullglob

  # Remove doc/ if now empty
  rmdir "doc" 2>/dev/null || echo "  Note: doc/ not empty after migration — check manually."
fi

# -- docs/ (old scripts) → example_scripts/ --------------------------------
if [ -d "docs/scripts" ]; then
  echo "  Migrating docs/scripts/ → example_scripts/ ..."
  find "docs/scripts" -type f -exec mv {} "example_scripts/" \;
  rm -rf "docs/scripts"
fi

# -- docs/src/02_quickstart → docs/02_quickstart ---------------------------
if [ -d "docs/src/02_quickstart" ]; then
  echo "  Migrating docs/src/02_quickstart/ → docs/02_quickstart/ ..."
  find "docs/src/02_quickstart" -type f -exec mv {} "docs/02_quickstart/" \;
  rm -rf "docs/src/02_quickstart"
fi

# -- data/ → data_examples/ ------------------------------------------------
if [ -d "data" ]; then
  echo "  Migrating data/ → data_examples/ ..."
  # Move subdirs individually to avoid overwriting
  for item in data/*; do
    [ -e "$item" ] && mv "$item" "data_examples/"
  done
  rmdir "data" 2>/dev/null || echo "  Note: data/ not empty after migration — check manually."
fi

# -- src/ stays in place; just ensure it exists ----------------------------
# (already created above, nothing to move unless you want to reorganise internals)

# ---------------------------------------------------------------------------
# 4. Seed .gitkeep files so empty dirs are tracked by git
# ---------------------------------------------------------------------------
find . -path ./.git -prune -o -type d -empty -print | while read -r emptydir; do
  touch "${emptydir}/.gitkeep"
done

# ---------------------------------------------------------------------------
# 5. Seed placeholder READMEs in each top-level and docs/ subdir
# ---------------------------------------------------------------------------

write_readme() {
  local dir="$1"
  local title="$2"
  local body="$3"
  local target="${dir}/README.md"
  if [ ! -f "$target" ]; then
    cat > "$target" <<EOF
# ${title}

${body}
EOF
  fi
}

write_readme ".github"          ".github"          "GitHub Actions workflows and issue/PR templates."
write_readme "example_scripts"  "example_scripts"  "Standalone scripts demonstrating individual pipeline steps."
write_readme "notebook_examples" "notebook_examples" "Jupyter notebooks with end-to-end worked examples."
write_readme "data_examples"    "data_examples"    "Small fixture datasets for testing and quickstart demos. Large files are downloaded on demand — see docs/02_quickstart."
write_readme "docs"             "docs"             "Project documentation. Subdirectories follow the numbered curriculum below."
write_readme "examples"         "examples"         "Higher-level worked examples combining scripts and notebooks."
write_readme "ext"              "ext"              "External / vendored dependencies. Prefer submodules or package managers where possible."
write_readme "src"              "src"              "Core library source code."
write_readme "tests"            "tests"            "Unit and integration tests mirroring the src/ layout."

write_readme "docs/src"                           "docs/src"                           "Sphinx documentation build configuration."
write_readme "docs/01_install"                    "01 — Installation"                  "Installation instructions for all supported platforms and environments."
write_readme "docs/02_quickstart"                 "02 — Quickstart"                    "Minimal working examples to get up and running with KEGGREST, KOfam, and eggNOG annotations."
write_readme "docs/03_data_augmented_data_sqlitedb" "03 — Data & Augmented Data / SQLite DB" "How to obtain, augment, and index microbial genome/proteome collections into a local SQLite database."
write_readme "docs/04_preprocessing_showcase"     "04 — Preprocessing Showcase"        "Functional annotation workflows and preprocessing pipelines."
write_readme "docs/05_dictionary_learning"        "05 — Dictionary Learning"           "Sparse dictionary learning methods for functional profile embeddings."
write_readme "docs/06_deconvolution"              "06 — Deconvolution"                 "Cell-type / source deconvolution from bulk and single-cell functional profiles."
write_readme "docs/07_network"                    "07 — Network"                       "Gene / pathway network construction and analysis."
write_readme "docs/08_simulations"                "08 — Simulations"                   "Simulation frameworks for benchmarking embedding and deconvolution methods."
write_readme "docs/09_math"                       "09 — Mathematical Background"       "Theoretical notes, derivations, and references underpinning the methods."
write_readme "docs/10_assets"                     "10 — Assets"                        "Images, figures, and static files used in the documentation."

# ---------------------------------------------------------------------------
# 6. Print final tree
# ---------------------------------------------------------------------------
echo ""
echo "==> Done. New structure:"
if command -v tree &>/dev/null; then
  tree -L 3 --dirsfirst -a -I ".git"
else
  find . -path ./.git -prune -o -print | sort | \
    awk -F/ '{
      depth = NF - 2;
      indent = "";
      for (i=0; i<depth; i++) indent = indent "  ";
      print indent "└── " $NF
    }'
fi

echo ""
echo "==> Next steps:"
echo "    1. Review migrations above and commit: git add -A && git commit -m 'chore: reshape repository structure'"
echo "    2. Update any cross-references in README.md and docs/src/index.rst"
echo "    3. Remove placeholder .gitkeep files from dirs you populate"
