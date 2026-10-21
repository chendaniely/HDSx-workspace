#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 🤖 AI edit (Claude), 2026-10-20: this file.
# Runs inside the freshly built course image, from the repository root, before
# the build workflow pushes it. Any failure stops the push. The sess revision,
# the CRAN snapshot, the R package list and the Python pins are read from the
# files that set them, so changing those needs no edit here. R, Quarto and
# Python versions are printed for the log; the image recipe pins them.
# -----------------------------------------------------------------------------
set -uo pipefail
fail=0
check() {
  if eval "$2" >/dev/null 2>&1; then echo "PASS  $1"; else echo "FAIL  $1"; fail=1; fi
}

echo "R:      $(R --version | head -n 1)"
echo "Quarto: $(quarto --version)"
echo "Python: $(python3 --version)"

installer=.devcontainer/install-packages.sh
sess_revision=$(grep -oE 'VSCODE_R_SESS_REVISION=[^ ]+' "$installer" | cut -d= -f2)
cran_snapshot=$(grep -oE 'CRAN_SNAPSHOT="[^"]+"' "$installer" | cut -d'"' -f2)
r_extras=$(grep -oE 'pkgs <- c\([^)]*\)' "$installer")
export sess_revision cran_snapshot r_extras
check "sess is the build from the pinned vscode-R release" \
  'Rscript -e "stopifnot(identical(packageDescription(\"sess\", fields = \"Config/vscode-R/source-revision\"), Sys.getenv(\"sess_revision\")))"'
check "course R packages load" \
  'Rscript -e "eval(parse(text = Sys.getenv(\"r_extras\"))); for (p in c(\"tidyverse\", \"knitr\", \"sess\", pkgs)) suppressPackageStartupMessages(library(p, character.only = TRUE))"'
check "install.packages() uses the CRAN snapshot" \
  'Rscript -e "stopifnot(identical(getOption(\"repos\")[[\"CRAN\"]], Sys.getenv(\"cran_snapshot\")))"'
check "the R profile shows plots from R started by hand" \
  'grep -q show_plots_in_vscode "$HOME/.Rprofile"'
# vscode-R sources ~/.Rprofile before it connects sess, so an error there would
# cost Run Cell its connection. Start R the way both kinds of VS Code terminal
# do and fail on any startup error.
check "R starts cleanly in a terminal R was typed into" \
  'out=$(printf "cat(\"R-STARTED\\\\n\")\\n" | TERM_PROGRAM=vscode R --quiet --interactive --no-save 2>&1); grep -q R-STARTED <<<"$out" && ! grep -qi error <<<"$out"'
check "R starts cleanly in a Run Cell terminal" \
  'out=$(printf "cat(\"R-STARTED\\\\n\")\\n" | TERM_PROGRAM=vscode SESS_DISCOVERY_FILE=/nonexistent R --quiet --interactive --no-save 2>&1); grep -q R-STARTED <<<"$out" && ! grep -qi error <<<"$out"'
check "Python packages match constraints.txt" 'python3 - <<EOF
import re, importlib.metadata as md
bad = []
for name, version in re.findall(r"^([A-Za-z0-9_.-]+)==(\S+)", open(".devcontainer/constraints.txt").read(), re.M):
    try:
        if md.version(name) != version: bad.append((name, md.version(name), version))
    except md.PackageNotFoundError:
        bad.append((name, None, version))
assert not bad, bad
EOF'
out=$(mktemp -d)
check "practice_report.qmd renders" "quarto render practice_report.qmd --output-dir '$out' --quiet"
check "a PDF renders through Typst" "quarto render practice_report.qmd --to typst --output-dir '$out/typst' --quiet && test -s '$out/typst/practice_report.pdf'"
tlmgr=$(ls -d "$HOME"/.TinyTeX/bin/*/tlmgr 2>/dev/null | head -n 1)
latex_before=$("${tlmgr:-false}" info --only-installed --data name 2>/dev/null | wc -l)
check "a PDF renders through LaTeX (TinyTeX)" "quarto render practice_report.qmd --to pdf --output-dir '$out/latex' --quiet && test -s '$out/latex/practice_report.pdf'"
latex_after=$("${tlmgr:-false}" info --only-installed --data name 2>/dev/null | wc -l)
echo "LaTeX packages: $latex_before before the PDF render, $latex_after after" \
     "(any difference was downloaded during the render, so not in the image)"
check "a Python chunk renders through Jupyter" "printf -- '---\ntitle: py\n---\n\n\`\`\`{python}\nimport pandas as pd\nprint(pd.__version__)\n\`\`\`\n' > '$out/py.qmd' && quarto render '$out/py.qmd' --quiet"

exit $fail
