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
2. Wait about 5 minutes while the Codespace starts. R, Quarto, and Python come
   preinstalled, and the editor opens once they are. VS Code then takes a few
   more seconds to load its tools. It's ready when:
   - you've answered the **"Do you trust the authors of the files in this
     folder?"** box with **Trust Folder & Continue** (until then the bottom bar
     says **Restricted Mode** and the Quarto and R tools stay switched off);
   - the bottom bar no longer says **Activating Extensions…** and shows
     **Quarto** with a version number;
   - in a `.qmd` file, **Run Cell** appears above each R code chunk.

   If that hasn't happened after a couple of minutes, open **View → Command
   Palette**, run **Codespaces: View Creation Log**, and send the log to the
   instructor.
   <!-- 🤖 AI edit (Claude), 2026-10-20/21: this step and its readiness
   checks. -->
3. In the file list on the left, open **`practice_report.qmd`**. This root file
   is your Assignment 1 starter.
4. Save the file, open **View → Command Palette**, run **Quarto: Render
   Document**, and choose **Render HTML**. (The **Preview** button at the
   top-right of the editor renders it too, without that menu.) To see the
   result, click `practice_report.html` in the file list on the left: it
   opens in a preview tab inside VS Code. It
   should show a chart with no red error messages. After each render, close
   that tab and click the file again. Plots from **Run Cell** appear in a plot
   tab inside VS Code.
   For a PDF, run **Quarto: Render Document** and choose **Render PDF
   (Typst)**. Typst comes with Quarto, is fast, and keeps characters such as
   Greek letters and emoji that the LaTeX option can silently drop. Click the
   PDF in the file list to see it in a tab, just like the HTML. To open a file
   in your own browser instead (for example, slides to present full screen or
   print), right-click it in the file list and choose **Download**.
   <!-- 🤖 AI edit (Claude), 2026-10-20: the preview tabs (HTML and PDF),
   Typst for PDF, and Download (the port-8000 browser-tab steps are gone with
   the server). -->
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
`.devcontainer/install-packages.sh`; its Python packages are declared in
`.devcontainer/requirements.txt`. Every package version is pinned for the
term, so a Codespace made in December matches one made today: R packages come
from a dated CRAN snapshot (also what `install.packages()` uses inside the
Codespace, so packages released after that date are not available; ask the
instructor if you need one), and Python versions are fixed in
`.devcontainer/constraints.txt`. Do not initialize
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
