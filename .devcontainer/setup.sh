#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# SPPH 381H student-workspace Codespace post-create setup.
#
# Installs the few packages NOT already in the rocker tidyverse image (via
# install-packages.sh), then runs a self-test so you can see at a glance what
# works. We deliberately do NOT use `set -e`: if one optional package fails,
# the rest of setup should
# still finish and the self-test should still print, so the failure is visible
# instead of silently aborting the whole container build.
# -----------------------------------------------------------------------------
set -uo pipefail

# 🤖 AI edit (Claude), 2026-10-20: this block and the SETUP COMPLETE lines.
# "waitFor" in devcontainer.json keeps the editor closed until this script
# ends. Say where it is anyway, here and at the end, and warn in any
# interactive R started before the end: ~/.Rprofile warns while the marker
# file exists. An interrupted setup keeps the marker, so if the editor opens
# on an incomplete Codespace, it keeps warning.
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

# 🤖 AI edit (Claude), 2026-10-20: this block (the installs moved to
# install-packages.sh, which the course image's build also runs).
# In a Codespace made from the course image everything is already installed,
# so this finishes in seconds.
bash .devcontainer/install-packages.sh

# 🤖 AI edit (Claude), 2026-10-20: this block.
# R typed by hand saves its plots to .r-plots/ in the workspace (see
# install-packages.sh). Keep that folder out of commits without touching the
# student's .gitignore, so syncing the fork never conflicts.
if [ -d .git ] && ! grep -qx '/.r-plots/' .git/info/exclude 2>/dev/null; then
  echo '/.r-plots/' >> .git/info/exclude
fi

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
