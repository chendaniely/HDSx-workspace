#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPPH 381H student-workspace Codespace post-create setup.
#
# Installs the few packages NOT already in the rocker tidyverse image, then
# runs a self-test so you can see at a glance what works. We deliberately do
# NOT use `set -e`: if one optional package fails, the rest of setup should
# still finish and the self-test should still print, so the failure is visible
# instead of silently aborting the whole container build.
# -----------------------------------------------------------------------------
set -uo pipefail

# 🤖 AI edit (Claude), 2026-10-20: this block and the SETUP COMPLETE lines.
# Codespaces opens the editor while this script is still running. Say so here,
# at the end, and in any interactive R started before the end: ~/.Rprofile
# warns while the marker file exists. An interrupted setup keeps the marker, so
# its incomplete Codespace keeps warning too.
SETUP_MARKER="$HOME/.codespace-setup-running"
touch "$SETUP_MARKER"
if ! grep -q 'codespace-setup-running' "$HOME/.Rprofile" 2>/dev/null; then
  cat >> "$HOME/.Rprofile" <<'EOF'
# Added by .devcontainer/setup.sh: warn while the Codespace is still installing.
if (interactive() && file.exists("~/.codespace-setup-running")) {
  message("\n⏳ The Codespace is still installing. Some packages may be missing, and\n",
          "   plots may not reach VS Code, until the setup terminal says SETUP COMPLETE.\n",
          "   Then close this R terminal (trash-can icon) and run your code again.\n")
}
EOF
fi
echo "=========================================================="
echo "⏳ SETUP IN PROGRESS: installing packages (a few minutes)."
echo "   Wait for SETUP COMPLETE at the end of this log before"
echo "   running code."
echo "=========================================================="

# 🤖 AI edit (Claude), 2026-09-29, revised 2026-10-20: this block, its place
# first in the script, and the sess self-test line.
# sess connects R terminals to the VS Code R extension, which is how plots and
# View() reach the editor. vscode-R 3.2+ accepts only the sess built from its own
# release. Any other copy gets an easily missed "Install bundled sess" pop-up,
# and until someone clicks it, plots silently go to Rplots.pdf. r-universe builds
# from vscode-R's main branch, which drifts from the release, so install the copy
# inside the pinned release file. It goes first so plots reach VS Code within
# seconds, not after the slow package builds below. When bumping
# "REditorSupport.r@..." in devcontainer.json, bump VSCODE_R_VERSION and its
# checksum (sha256sum of the release's r-<version>.vsix) here too.
export VSCODE_R_VERSION=3.2.0
export VSCODE_R_SHA256=fbfd1dad22c5ab696750d201d4732ce30c032f22265d4efe2b220eb4361efd1e
echo "==> Installing sess from vscode-R ${VSCODE_R_VERSION} (sends plots from R to VS Code)..."
Rscript -e '
  version <- Sys.getenv("VSCODE_R_VERSION")
  vsix <- tempfile(fileext = ".vsix")
  download.file(sprintf("https://github.com/REditorSupport/vscode-R/releases/download/v%s/r-%s.vsix",
                        version, version), vsix, mode = "wb", quiet = TRUE)
  stopifnot("vscode-R release file failed its checksum" =
              tools::sha256sum(vsix) == Sys.getenv("VSCODE_R_SHA256"))
  bundled <- "extension/dist/resources/sess/"
  unzip(vsix, files = grep(paste0("^", bundled), unzip(vsix, list = TRUE)$Name, value = TRUE),
        exdir = tempdir())
  pkg <- file.path(tempdir(), bundled)
  imports <- strsplit(read.dcf(file.path(pkg, "DESCRIPTION"), "Imports"), ",")[[1]]
  need <- setdiff(trimws(sub("[(].*", "", imports)), rownames(installed.packages()))
  if (length(need)) install.packages(need, repos = "https://cloud.r-project.org")
  install.packages(pkg, repos = NULL, type = "source")
'

echo "==> Installing extra R packages (Table 1, dashboards, optional demos)..."
Rscript -e '
  pkgs <- c("gt", "gtsummary", "DT", "janitor", "scales", "plotly", "shiny", "reticulate")
  need <- setdiff(pkgs, rownames(installed.packages()))
  if (length(need)) install.packages(need, repos = "https://cloud.r-project.org")
  have <- intersect(pkgs, rownames(installed.packages()))
  cat("R extras present:", paste(have, collapse = ", "), "\n")
'

echo "==> Installing Python packages (Week 5 polyglot / reticulate demo)..."
python3 -m pip install --upgrade pip >/dev/null
python3 -m pip install -r .devcontainer/requirements.txt

echo ""
echo "=================== TOOLCHAIN SELF-TEST ==================="
echo "-- R --";       R --version | head -n 1
echo "-- Quarto --";  quarto --version
echo "-- Python --";  python3 --version
echo "-- pandas --";  python3 -c "import pandas as pd; print('pandas', pd.__version__)" || echo "pandas NOT available"
echo "-- sess --";    Rscript -e 'cat("sess", format(packageVersion("sess")), packageDescription("sess", fields = "Config/vscode-R/source-revision"), "\n")' 2>/dev/null || echo "sess NOT available (plots will not show in VS Code)"
echo ""
echo "-- quarto check (verifies R + Python + Jupyter integration) --"
quarto check || true
echo "=========================================================="
rm -f "$SETUP_MARKER"
echo "✅ SETUP COMPLETE. If every section above printed a version with"
echo "no error, the environment is ready. If something failed, copy this"
echo "whole log and send it to the instructor so it can be fixed. Close"
echo "any R terminal opened before this message, then run your code again."
