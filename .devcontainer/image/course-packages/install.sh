#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 🤖 AI edit (Claude), 2026-10-20: this file.
# Installs the course packages into the course image by running
# .devcontainer/install-packages.sh, the same script setup.sh runs in a
# Codespace. A feature only sees its own folder, so the build workflow copies
# that script and its package lists in here first. It runs as the Codespace
# user, so files end up owned exactly as a Codespace's own setup leaves them
# (students can still add and update packages).
# -----------------------------------------------------------------------------
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for f in install-packages.sh requirements.txt constraints.txt; do
  if [ ! -f "$here/$f" ]; then
    echo "Missing $f: copy .devcontainer/$f into this folder first" \
         "(.github/workflows/build-image.yml does this)." >&2
    exit 1
  fi
done

# The Python feature's PATH entry is not always applied yet during a build.
export PATH="/usr/local/python/current/bin:$PATH"
chmod -R a+rX "$here"
sudo -u "${_REMOTE_USER:-rstudio}" -H env "PATH=$PATH" bash "$here/install-packages.sh"
