#!/usr/bin/env bash
# =============================================================================
# setup_sphinx_docs.sh
# Scaffolds a complete Sphinx documentation skeleton under docs/
#
# What it does:
#   1. Writes docs/conf.py          (Sphinx config, HTML theme)
#   2. Writes docs/index.rst        (master index with clickable toctree)
#   3. Writes docs/Makefile         (standard Sphinx Makefile)
#   4. Writes docs/make.bat         (Windows equivalent)
#   5. Writes an index.rst inside every numbered chapter folder
#
# Run from the ROOT of your git repository AFTER reshape_repo.sh.
# Safe to re-run: existing files are NOT overwritten.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Safety check
# ---------------------------------------------------------------------------
if [ ! -d ".git" ]; then
  echo "ERROR: Run this script from the root of your git repository."
  exit 1
fi
if [ ! -d "docs" ]; then
  echo "ERROR: docs/ directory not found. Run reshape_repo.sh first."
  exit 1
fi

echo "==> Setting up Sphinx documentation scaffold..."

# Helper: write a file only if it does not already exist
write_file() {
  local path="$1"
  local content="$2"
  if [ -f "$path" ]; then
    echo "  SKIP (exists): $path"
  else
    # Create parent dir just in case
    mkdir -p "$(dirname "$path")"
    printf '%s' "$content" > "$path"
    echo "  WRITE:         $path"
  fi
}

# ===========================================================================
# 1. docs/conf.py
# ===========================================================================
write_file "docs/conf.py" '# =============================================================================
# Sphinx configuration for functional_profiles
# docs/conf.py
# =============================================================================

import os
import sys

# If your Python package lives in src/, expose it to autodoc
sys.path.insert(0, os.path.abspath("../src"))

# ---------------------------------------------------------------------------
# Project information
# ---------------------------------------------------------------------------
project   = "functional_profiles"
author    = "Maria Persico"
copyright = "2025, Maria Persico"
release   = "0.1.0"

# ---------------------------------------------------------------------------
# General configuration
# ---------------------------------------------------------------------------
extensions = [
    "sphinx.ext.autodoc",        # auto-document Python docstrings
    "sphinx.ext.napoleon",       # Google / NumPy docstring style
    "sphinx.ext.viewcode",       # add [source] links to API pages
    "sphinx.ext.mathjax",        # render LaTeX maths (needed for 09_math)
    "myst_parser",               # parse Markdown (.md) files as well as .rst
]

# Accept both .rst and .md source files
source_suffix = {
    ".rst": "restructuredtext",
    ".md":  "markdown",
}

templates_path   = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]

# ---------------------------------------------------------------------------
# HTML output — using the clean Read the Docs theme
# ---------------------------------------------------------------------------
html_theme = "sphinx_rtd_theme"

html_theme_options = {
    "navigation_depth":   4,
    "collapse_navigation": False,
    "titles_only":        False,
}

html_static_path = ["10_assets"]

# ---------------------------------------------------------------------------
# MyST-Parser options (Markdown support)
# ---------------------------------------------------------------------------
myst_enable_extensions = [
    "colon_fence",   # ::: fenced directives
    "deflist",       # definition lists
    "dollarmath",    # $...$ and $$...$$ math
]
'

# ===========================================================================
# 2. docs/index.rst  —  master index with clickable toctree
# ===========================================================================
write_file "docs/index.rst" 'functional_profiles
===================

**Building functional profile embeddings to feed sparsity-based methods
for single-cell and bulk transcriptomics.**

This documentation walks through the full pipeline — from obtaining and
annotating microbial genomes with KEGG / KOfam / eggNOG, through sparse
dictionary learning and deconvolution, to network and mathematical
foundations.

.. toctree::
   :maxdepth:  2
   :numbered:
   :caption:   Contents

   01_install/index
   02_quickstart/index
   03_data_augmented_data_sqlitedb/index
   04_preprocessing_showcase/index
   05_dictionary_learning/index
   06_deconvolution/index
   07_network/index
   08_simulations/index
   09_math/index

.. toctree::
   :maxdepth:  1
   :caption:   Project

   src/api


Indices and tables
------------------

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`
'

# ===========================================================================
# 3. docs/src/api.rst  — API autodoc stub
# ===========================================================================
write_file "docs/src/api.rst" 'API Reference
=============

.. automodule:: functional_profiles
   :members:
   :undoc-members:
   :show-inheritance:
'

# ===========================================================================
# 4. docs/Makefile
# ===========================================================================
write_file "docs/Makefile" '# Minimal Sphinx Makefile
SPHINXOPTS    ?=
SPHINXBUILD   ?= sphinx-build
SOURCEDIR     = .
BUILDDIR      = _build

.PHONY: help Makefile

help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

%: Makefile
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
'

# ===========================================================================
# 5. docs/make.bat  (Windows)
# ===========================================================================
write_file "docs/make.bat" '@ECHO OFF
pushd %~dp0
if "%SPHINXBUILD%" == "" (set SPHINXBUILD=sphinx-build)
set SOURCEDIR=.
set BUILDDIR=_build
%SPHINXBUILD% >NUL 2>NUL
if errorlevel 9009 (
    echo.The Sphinx module was not found. Make sure you have Sphinx installed.
    exit /b 1
)
if "%1" == "" goto help
%SPHINXBUILD% -M %1 %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%
goto end
:help
%SPHINXBUILD% -M help %SOURCEDIR% %BUILDDIR% %SPHINXOPTS% %O%
:end
popd
'

# ===========================================================================
# 6. Per-chapter index.rst files
#    Each entry: (folder  title  one-line description)
# ===========================================================================

declare -A CHAPTER_TITLE
declare -A CHAPTER_DESC
declare -A CHAPTER_CONTENT

CHAPTER_TITLE["01_install"]="Installation"
CHAPTER_DESC["01_install"]="How to install the package and its dependencies."
CHAPTER_CONTENT["01_install"]="requirements
   conda_environment
   pip_install"

CHAPTER_TITLE["02_quickstart"]="Quickstart"
CHAPTER_DESC["02_quickstart"]="Minimal working examples using KEGGREST, KOfam, and eggNOG."
CHAPTER_CONTENT["02_quickstart"]="KEGGREST
   KOFAM
   eggNOG"

CHAPTER_TITLE["03_data_augmented_data_sqlitedb"]="Data & Augmented Data / SQLite DB"
CHAPTER_DESC["03_data_augmented_data_sqlitedb"]="Obtaining microbial genomes and proteomes, augmenting metadata, and indexing into a local SQLite database."
CHAPTER_CONTENT["03_data_augmented_data_sqlitedb"]="data_sources
   augmentation
   sqlite_schema"

CHAPTER_TITLE["04_preprocessing_showcase"]="Preprocessing Showcase"
CHAPTER_DESC["04_preprocessing_showcase"]="Functional annotation workflows and preprocessing pipelines from raw sequences to profile matrices."
CHAPTER_CONTENT["04_preprocessing_showcase"]="annotation_workflows
   profile_matrices
   quality_control"

CHAPTER_TITLE["05_dictionary_learning"]="Dictionary Learning"
CHAPTER_DESC["05_dictionary_learning"]="Sparse dictionary learning methods for constructing functional profile embeddings."
CHAPTER_CONTENT["05_dictionary_learning"]="overview
   sparse_coding
   learned_dictionaries
   evaluation"

CHAPTER_TITLE["06_deconvolution"]="Deconvolution"
CHAPTER_DESC["06_deconvolution"]="Cell-type and source deconvolution from bulk and single-cell functional profiles."
CHAPTER_CONTENT["06_deconvolution"]="overview
   bulk_deconvolution
   singlecell_deconvolution
   benchmarking"

CHAPTER_TITLE["07_network"]="Network Analysis"
CHAPTER_DESC["07_network"]="Gene and pathway network construction, community detection, and functional enrichment."
CHAPTER_CONTENT["07_network"]="overview
   network_construction
   community_detection
   enrichment"

CHAPTER_TITLE["08_simulations"]="Simulations"
CHAPTER_DESC["08_simulations"]="Simulation frameworks for benchmarking embedding and deconvolution methods."
CHAPTER_CONTENT["08_simulations"]="overview
   synthetic_data
   benchmarking_framework"

CHAPTER_TITLE["09_math"]="Mathematical Background"
CHAPTER_DESC["09_math"]="Theoretical notes, derivations, and key references underpinning all methods."
CHAPTER_CONTENT["09_math"]="overview
   sparse_representations
   matrix_factorisation
   probabilistic_models
   references"

for chapter in \
    "01_install" \
    "02_quickstart" \
    "03_data_augmented_data_sqlitedb" \
    "04_preprocessing_showcase" \
    "05_dictionary_learning" \
    "06_deconvolution" \
    "07_network" \
    "08_simulations" \
    "09_math"
do
  dir="docs/${chapter}"
  title="${CHAPTER_TITLE[$chapter]}"
  desc="${CHAPTER_DESC[$chapter]}"
  toc_entries="${CHAPTER_CONTENT[$chapter]}"

  # Build the underline to match title length
  underline=$(printf '%0.s-' $(seq 1 ${#title}))

  # Build toctree entries (indented)
  toc_block=""
  while IFS= read -r entry; do
    toc_block="${toc_block}   ${entry}
"
  done <<< "$toc_entries"

  write_file "${dir}/index.rst" "${title}
${underline}

${desc}

.. toctree::
   :maxdepth: 2
   :caption: ${title}

${toc_block}
.. note::
   This chapter is under active development.
   Contributions welcome — see the project README.
"

done

# ===========================================================================
# 7.  requirements-docs.txt  (so CI can install Sphinx deps in one line)
# ===========================================================================
write_file "docs/requirements-docs.txt" '# Sphinx documentation dependencies
sphinx>=7.0
sphinx-rtd-theme>=2.0
myst-parser>=3.0
'

# ===========================================================================
# 8. Summary
# ===========================================================================
echo ""
echo "==> Sphinx scaffold complete. Files written:"
echo ""
find docs -name "*.rst" -o -name "conf.py" -o -name "requirements-docs.txt" \
  | sort | sed 's/^/    /'
echo ""
echo "==> To build locally:"
echo "    pip install -r docs/requirements-docs.txt"
echo "    sphinx-build docs docs/_build"
echo "    open docs/_build/index.html"
echo ""
echo "==> Update your CI workflow to:"
echo "    run: sphinx-build docs docs/_build"
echo ""
echo "==> Next: fill in the stub .rst files inside each chapter folder."
echo "    Markdown files (.md) in those folders are auto-picked up by MyST."
