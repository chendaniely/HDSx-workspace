# SPPH 381H — Your Personal Workspace

This is **your** working project for **SPPH 381H: Health Data Science (AI and
Knowledge Translation)**. Fork this repository once, then do your individual
course work here. The course book is a separate, read-only reference; do not
copy book source files into this repository unless an assignment explicitly
tells you to.

## Project map

```text
.
├── assignments/          <- Stable starter/template paths and your submission folders
├── data/
│   └── patients.csv      <- Small synthetic dataset for Assignment 1 practice
├── examples/nhanes-equity/data/
│   ├── nhanes_equity_v6.csv
│   └── nhanes_equity_v6.rds
├── output/               <- Code-generated outputs
├── practice_report.qmd   <- Assignment 1 source at the repository root
├── references.bib        <- Course bibliography entries used by later starters
├── _quarto.yml           <- Makes code execute from this project root
└── .gitignore            <- Ignores temporary, private, and machine-specific files
```

The cached NHANES files are committed course assets for offline classroom use.
Treat them as read-only inputs. Do not replace them with private or identifiable
health data.

## Getting started (the full walkthrough is on the Week 2 course page)

1. On this repository's GitHub page, click the green **`< > Code`** button →
   **Codespaces** tab → **Create codespace on main**.
2. Wait about 10 minutes while the environment builds (R, Quarto, and Python
   install automatically). The editor opens only once everything is
   installed, so you can start as soon as you see it.
   <!-- 🤖 AI edit (Claude), 2026-10-20: this step. -->
3. In the file list on the left, open **`practice_report.qmd`**. This root file
   is your Assignment 1 starter.
4. Save the file, open **View → Command Palette**, and run **Quarto: Render
   Document**. (If a **Render** button appears at the top-right of the editor,
   it does the same thing.) To see the result, click `practice_report.html` in
   the file list on the left: it opens in a preview tab inside VS Code. It
   should show a chart with no red error messages. After each render, close
   that tab and click the file again. Plots from **Run Cell** appear in a plot
   tab inside VS Code.
   <!-- 🤖 AI edit (Claude), 2026-10-20: the preview tab. -->
   To open the result in a full browser tab instead (handy for slides), open
   the **Ports** tab (next to **Terminal**), click the globe icon on the
   **Rendered reports** row, and click `practice_report.html` in the list that
   opens; reload that tab after each render. If that tab is empty or shows an
   error, run
   `pkill -f http.server; python3 -m http.server 8000 --bind 127.0.0.1` in the
   terminal, leave it running, and reload the tab. Never click **Make Public**
   on this port: anyone with the link could then browse your whole workspace.
   <!-- 🤖 AI edit (Claude), 2026-09-29: how to view rendered output in this step. -->
5. Make the Assignment 1 edits, render again, then commit both
   `practice_report.qmd` and `practice_report.html` and sync your work.

## Later assignments

The `assignments/` folder contains student-only starters and blank submission
folders for A2–A9. Use the exact starter and destination named in the course
brief. Work from the repository root so paths such as
`examples/nhanes-equity/data/nhanes_equity_v6.csv` resolve consistently.

Required rendered artifacts are part of the submission and must be committed.
Do not add a global `*.html` or `*.pdf` rule to `.gitignore`. Stage only the
source, outputs, and rendered files requested by the assignment.

The Codespace is the course dependency baseline. Its R package list is in
`.devcontainer/setup.sh`; its Python packages are declared in
`.devcontainer/requirements.txt`. Every version is pinned for the term, so a
Codespace made in December matches one made today: R packages come from a dated
CRAN snapshot (also what `install.packages()` uses inside the Codespace), and
Python versions are fixed in `.devcontainer/constraints.txt`. Do not initialize
`renv`. If you add a package with instructor approval, document it in the
assignment dependency note and update the appropriate devcontainer list so a
fresh Codespace can install it.
<!-- 🤖 AI edit (Claude), 2026-10-20: the sentences on pinned versions. -->

## Important

- **`data/` is read-only.** Import from it; never save into it.
- **`output/` is generated** by your code.
- The practice dataset is **synthetic** — it is not real patient data. **Never
  put real, private, or personal health data in this repository.**
- Instructor solutions and answer keys are not stored in this repository.
