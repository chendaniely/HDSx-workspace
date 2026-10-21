#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 🤖 AI edit (Claude), 2026-10-20: this file, split out of setup.sh.
# Installs what the course adds to the rocker image: R packages, sess, Python
# packages, and the ~/.Rprofile settings. The course image's build runs it once
# (see .devcontainer/image/), so a Codespace starts with all of it in place.
# setup.sh runs it again in every new Codespace, where it finds everything
# installed and finishes in seconds. Safe to run any number of times.
#
# Like setup.sh, no `set -e`: one failed package should not hide the others.
# The image build's smoke test is what catches a failure there.
# -----------------------------------------------------------------------------
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 🤖 AI edit (Claude), 2026-10-20: this block and every use of CRAN_SNAPSHOT.
# R packages come from Posit's CRAN snapshot of the day the base image was
# built (see "image" in image/devcontainer.json), so every Codespace gets the
# same versions, all of them consistent with the tidyverse already in the
# image. The snapshot serves Linux binaries, so nothing compiles. ~/.Rprofile
# points install.packages() at it too, so a package a student adds matches the
# ones already installed. Python packages are pinned by constraints.txt,
# resolved for the same date. Bump all three together.
export CRAN_SNAPSHOT="https://p3m.dev/cran/__linux__/noble/2026-07-06"
if ! grep -q 'CRAN snapshot' "$HOME/.Rprofile" 2>/dev/null; then
  cat >> "$HOME/.Rprofile" <<EOF
# Added by .devcontainer/install-packages.sh: install packages from the course's CRAN snapshot.
options(repos = c(CRAN = "$CRAN_SNAPSHOT"))
EOF
fi

# 🤖 AI edit (Claude), 2026-10-20: this block.
# Only R started by vscode-R (Run Cell, or "R: Create R Terminal") connects to
# VS Code; vscode-R marks those terminals with SESS_DISCOVERY_FILE. R typed by
# hand into any other terminal is not connected, and its plots would go to an
# empty Rplots.pdf. Instead, that R draws off-screen, and after each command
# that started or changed a plot, saves it as a PNG and opens it in a VS Code
# tab, which refreshes in place. (The plot.new/grid.newpage hooks catch a plot
# redrawn identically after its tab was closed; the student's own current
# device is restored after the PNG is written.) No message, no Rplots.pdf. The PNG lives in .r-plots/
# inside the workspace, because VS Code asks before opening a file from outside
# it; setup.sh keeps that folder out of commits. Rscript and Quarto renders are
# not interactive, so they are unaffected.
if ! grep -q 'show_plots_in_vscode' "$HOME/.Rprofile" 2>/dev/null; then
  cat >> "$HOME/.Rprofile" <<'EOF'
# Added by .devcontainer/install-packages.sh: show plots from R started by hand.
if (interactive() && Sys.getenv("TERM_PROGRAM") == "vscode" &&
    !nzchar(Sys.getenv("SESS_DISCOVERY_FILE"))) invisible(local({
  plot_dir <- file.path(Sys.getenv("CODESPACE_VSCODE_FOLDER", tempdir()), ".r-plots")
  png_file <- file.path(plot_dir, "Rplot.png")
  shown <- NULL
  new_page <- FALSE
  setHook("plot.new", function(...) new_page <<- TRUE)
  setHook("grid.newpage", function(...) new_page <<- TRUE)
  options(device = function(...) {
    grDevices::pdf(NULL, bg = "white")
    grDevices::dev.control("enable")
  })
  addTaskCallback(function(...) {
    try(if (grDevices::dev.cur() > 1) {
      plot_now <- grDevices::recordPlot()
      if (length(plot_now[[1]]) && (new_page || !identical(plot_now[[1]], shown))) {
        shown <<- plot_now[[1]]
        dir.create(plot_dir, showWarnings = FALSE)
        current <- grDevices::dev.cur()
        grDevices::png(png_file, width = 7, height = 5, units = "in", res = 96)
        grDevices::replayPlot(plot_now)
        grDevices::dev.off()
        grDevices::dev.set(current)
        new_page <<- FALSE
        system2("code", png_file, wait = FALSE)
      }
    }, silent = TRUE)
    TRUE
  }, name = "show_plots_in_vscode")
}))
EOF
fi

# 🤖 AI edit (Claude), 2026-09-29, revised 2026-10-20: this block, its place
# before the other packages, and the sess self-test line in setup.sh.
# sess connects R terminals to the VS Code R extension, which is how plots and
# View() reach the editor. vscode-R 3.2+ accepts only the sess built from its own
# release. Any other copy gets an easily missed "Install bundled sess" pop-up,
# and until someone clicks it, plots silently go to Rplots.pdf. r-universe builds
# from vscode-R's main branch, which drifts from the release, so install the copy
# inside the pinned release file, unless that exact build is already installed.
# When bumping "REditorSupport.r@..." in devcontainer.json, bump these three:
# the version, the sha256sum of the release's r-<version>.vsix, and the
# Config/vscode-R/source-revision line of the sess DESCRIPTION inside it. Then
# rebuild the image and re-pin its digest: the image carries sess, and without
# a rebuild every new Codespace downloads the new sess at creation.
export VSCODE_R_VERSION=3.2.0
export VSCODE_R_SHA256=fbfd1dad22c5ab696750d201d4732ce30c032f22265d4efe2b220eb4361efd1e
export VSCODE_R_SESS_REVISION=git-tree:25da80133148500e2fc25eff593f49674324022e
echo "==> Installing sess from vscode-R ${VSCODE_R_VERSION} (sends plots from R to VS Code)..."
Rscript -e '
  have <- if (requireNamespace("sess", quietly = TRUE))
    packageDescription("sess", fields = "Config/vscode-R/source-revision")
  if (identical(have, Sys.getenv("VSCODE_R_SESS_REVISION"))) {
    cat("sess from vscode-R", Sys.getenv("VSCODE_R_VERSION"), "already installed\n")
  } else {
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
    if (length(need)) install.packages(need, repos = Sys.getenv("CRAN_SNAPSHOT"))
    install.packages(pkg, repos = NULL, type = "source")
  }
'

echo "==> Installing extra R packages (Table 1, dashboards, optional demos)..."
Rscript -e '
  pkgs <- c("gt", "gtsummary", "DT", "janitor", "scales", "plotly", "shiny", "reticulate")
  need <- setdiff(pkgs, rownames(installed.packages()))
  if (length(need)) install.packages(need, repos = Sys.getenv("CRAN_SNAPSHOT"))
  have <- intersect(pkgs, rownames(installed.packages()))
  cat("R extras present:", paste(have, collapse = ", "), "\n")
'

echo "==> Installing Python packages (Week 5 polyglot / reticulate demo)..."
# --disable-pip-version-check: in a prebuilt Codespace everything is already
# satisfied and pip needs no network, except for its own version check, which
# could stall setup (and the editor, via waitFor) if PyPI were slow.
python3 -m pip install --quiet --disable-pip-version-check "pip==26.1.2"
python3 -m pip install --quiet --disable-pip-version-check \
  -r "$here/requirements.txt" -c "$here/constraints.txt"
