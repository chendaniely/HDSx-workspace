# Course Codespace: maintainer notes

<!-- 🤖 AI edit (Claude), 2026-10-20/21: this file. -->

For instructors and TAs who maintain the SPPH 381H student Codespace. Students
don't need this file; their steps are in the top-level `README.md`.

Everything under "What students see" and "Findings" was checked on 2026-10-20
and 21 in fresh Codespaces opened in the browser (Chrome), the way students
open them.
The commit messages on this folder record each decision and its reasons.

## How it fits together

| File | Role |
|---|---|
| `devcontainer.json` | What a student's Codespace uses: the course image (pinned by digest), pinned VS Code extensions and settings, `setup.sh` as `postCreateCommand`, and `waitFor` so the editor opens only after setup. |
| `image/devcontainer.json` | Recipe for the course image: rocker's tidyverse image (R 4.6.1, by digest), Quarto 1.10.19 with TinyTeX, Python 3.11.17, and the local `course-packages` feature. |
| `install-packages.sh` | R packages from the CRAN snapshot (2026-07-06), sess from the pinned vscode-R release, Python packages pinned by `constraints.txt`, and the `~/.Rprofile` settings. Runs at image build, and again in `setup.sh`, where it finds everything installed and takes seconds. |
| `requirements.txt`, `constraints.txt` | The Python packages, and every version they resolve to (regenerate command in the header). |
| `../.github/workflows/build-image.yml` | Manual workflow: builds the image, renders `practice_report.qmd` in it (HTML and Typst), and pushes it to `ghcr.io/chendaniely/hdsx-workspace` only if both renders work. |

## Changing a version

1. Edit the pin where it lives: the image recipe, `install-packages.sh`,
   `requirements.txt`/`constraints.txt`, or the extension list in
   `devcontainer.json`. Extension-only changes need no image rebuild; skip to
   step 4.
2. Values that must move together:
   - vscode-R (`REditorSupport.r@…`) and the three `VSCODE_R_*` values in
     `install-packages.sh`, then an image rebuild, because the image carries sess.
   - the CRAN snapshot date, the rocker image's build date (comment at its
     digest), and `--exclude-newer` in `constraints.txt`.
3. Run **Actions → Build course image**. It pushes tag `build-<run>-<attempt>`.
   Pin the new image by its digest, not the tag: the digest (`sha256:…`) is
   computed from the image's contents, so like a commit SHA it names exactly
   one build, while a tag can move. Copy it from the
   [package page](https://github.com/chendaniely/HDSx-workspace/pkgs/container/hdsx-workspace)
   (or `docker buildx imagetools inspect ghcr.io/chendaniely/hdsx-workspace:<tag>`)
   into `"image"` in `devcontainer.json`. Keep the package public and don't
   prune pinned versions: every student Codespace pulls it anonymously, and a
   rebuild is not byte-identical.
4. Test in a fresh Codespace in the browser. The build only checks that the
   report renders, so check by hand:
   - **Run Cell** prints `[sess] Connected to VS Code` and its plot opens in an
     R Plot tab;
   - R typed into a new terminal starts with no error, and `hist(1:10)` opens a
     plot tab;
   - `getOption("repos")` in R shows the CRAN snapshot;
   - **Quarto: Render Document** works for Render HTML, Render PDF (Typst) and
     Render PDF (LaTeX);
   - a `{python}` chunk with `import pandas` renders.

## What students see

- **Startup:** about 4 minutes to a ready editor for a new Codespace, of which
  about 3¼ is downloading the 1.9 GB image; `setup.sh` takes about 18 s.
  Reopening an existing Codespace is much faster (a stopped one came back in
  about 30 s). Without the image, a new Codespace took about 9 minutes.
- **Trust prompt:** VS Code asks "Do you trust the authors of the files in this
  folder?" on first open. No repo-level way to turn it off was found. Until it
  is answered, the bottom bar says "Restricted Mode" and extensions are limited.
- **Ready signals** (README step 2): the packages are in place when the editor
  opens (`waitFor`); extensions finish loading a few seconds later, inside VS
  Code, so setup can't announce it. Ready means: trust answered, "Activating
  Extensions…" gone from the bottom bar, the Quarto status item showing its
  version, and Run Cell links above R chunks in a `.qmd`. The first Run Cell
  prints `[sess] Connected to VS Code`.
- **Rendering:** *Quarto: Render Document* opens a menu (Render HTML, PDF via
  Typst, PDF via LaTeX, MS Word). The **Preview** button renders the document's
  own format without the menu. Right after the editor opens, the first render
  command is sometimes ignored while the Quarto extension loads; running it
  again works.
- **Viewing:** clicking a rendered `.html` opens it in a tab with plotly, DT and
  revealjs working. The tab does not refresh after a re-render: close it and
  click the file again. Clicking a `.pdf` opens it in a tab. Right-click →
  **Download** for anything to open in the student's own browser.
- **Plots:** *Run Cell* starts an R that prints `[sess] Connected to VS Code`,
  and plots open in an R Plot tab. R typed by hand into a terminal isn't
  connected, so `~/.Rprofile` opens its plots as a PNG tab instead
  (`.r-plots/`, kept out of commits by `.git/info/exclude`).
- **Python notebooks:** work (Python 3.11.17 with pandas). On first run VS Code
  asks for a kernel: the right choice is **Python 3.11.17**
  (`/usr/local/python/current/bin/python`). The option marked *Recommended*,
  "Create Python Environment", makes an empty environment without pandas, and
  Python 3.12.3 (`/usr/bin/python3`) is the system Python, also without pandas.
- **Left as they are, to keep customizations minimal** (Dan, 2026-10-21:
  "let's leave minimal customizations"): while a rendered `.html` is open,
  Problems shows one CSS warning from Quarto's own output ("Do not use empty
  rulesets") and the file name turns yellow. Notifications also wait under the
  bell: install the GitHub Actions extension (suggested for
  `build-image.yml`), "periodically run git fetch?", and Mathematic's donation
  notice. Untested settings that would hide the first three:
  `html.validate.styles: false`, `git.autofetch: true`,
  `extensions.ignoreRecommendations: true`.

## Findings: what doesn't work in the browser client, and why

### Quarto's own preview (kept off: `quarto.render.previewType: "none"`)

- **Side pane (`internal`):** blank. It frames the forwarded port, and that
  port's GitHub sign-in can't load inside a frame.
- **Browser tab (`external`):** VS Code opens it after the render finishes, not
  on a click, so the browser blocks it as a pop-up. When pop-ups are allowed,
  Codespaces maps `localhost:PORT/report.html` to the port's root, `/`, where
  `quarto preview` serves "Not Found" once `_quarto.yml` exists.
- **`VSCODE_PROXY_URI`:** makes Quarto print the full forwarded URL, but the
  extension then never sees the `localhost` URL it waits for in its log, so it
  opens nothing in either mode.
- A browser tab opened by hand on the preview port does live-reload, but no
  port is forwarded (below) and the port changes with every preview.

### Ports (`otherPortsAttributes: { "onAutoForward": "ignore" }`)

Each preview and R port, when forwarded, popped up "Your application … is
available" with **Open in Browser** (landing on "Not Found") and **Make Public**,
and added a Ports-tab row that led nowhere useful. The port-8000 file server
added on 2026-09-29 was removed: click-to-view replaced it, and it served the
whole workspace, `.git` included.

### HTML viewers

| Extension | Result |
|---|---|
| `analytic-signal.preview-html` 1.0.0 (used) | Works; scripts run. Reads the file from disk, so no port. No refresh on re-render. |
| `searKing.preview-vscode` | Renders, but disables scripts ("Some content has been disabled"), so no interactive charts or tables. |
| `GingerTurtle.html-preview-pro`, `ms-vscode.live-server` | Serve the page on a port inside a frame: same sign-in problem as Quarto's pane. |
| vscode-R `browseURL("file.html")` | Works (HTML Viewer tab), but means typing R. |

### PDF viewers (VS Code has none built in: microsoft/vscode#249194)

| Extension | Result |
|---|---|
| `mathematic.vscode-pdf` 0.2.6 (used) | Works. A one-time donation notice in each new Codespace; no setting turns it off. |
| `AdamRaichu.pdf-viewer` 1.1.2 | Stuck on "Your PDF is loading…" on first open; very slow after that. |
| `tomoki1207.pdf` | UI-only, no web build: can't run in the browser client. |

### PDF rendering

Typst, bundled with Quarto, is the recommended route (README step 4): fast, and
it keeps literal Greek letters and emoji, which the LaTeX route silently drops
while still exiting 0 (UBC-MDS/mds-setup-check, `docs/render-matrix.md`).
TinyTeX is installed so the LaTeX choice works rather than errors; the first
LaTeX render prints a one-time "generating font names database" note.

### Extensions

- A pinned extension (`publisher.name@version`) wins over the unpinned copy the
  image's metadata asks for: Quarto stayed at 1.138.0 after 1.139.0 was
  released, marked `"pinned": true`.
- `-RDebugger.r-debugger` keeps out the R Debugger extension the rocker image
  adds (it popped up a "legacy r.path" warning after a window reload).
- The Python, Jupyter and Copilot extensions stay unpinned: they use VS Code's
  proposed APIs, and Codespaces always runs the newest VS Code.

### R sessions

Only R started by vscode-R (Run Cell, *R: Create R Terminal*) connects to VS
Code; vscode-R marks those terminals with `SESS_DISCOVERY_FILE`. vscode-R 3.2's
"R Interactive" window is marked experimental and needs the arf console, so Run
Cell is pinned to a plain R terminal (`r.interactive.executionTarget`).

## Next term

- **Python:** bump to a current release (note at the pin in
  `image/devcontainer.json`); 3.11's security support ends October 2027.
- **Faster startup:** the rocker base is 1.18 GB of the 1.9 GB image and
  includes RStudio Server, which this setup doesn't use. Our own layers are
  Quarto with TinyTeX (350 MB), the course packages (236 MB) and Python
  (133 MB).
- **Project template:** move this setup to `ehsanx/HDSx-project-template`; it can
  reuse the image. Template repos have no "Sync fork", so groups copy
  `.devcontainer/` in by hand.
- **Course book:** its viewing instructions still describe a preview pane and
  *Open Preview*; update them once students have synced their forks.
- **Image hosting:** under `chendaniely` for now, to move to `ehsanx` later.
