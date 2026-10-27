#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# 🤖 AI edit (Claude), 2026-10-20: this file.
# Runs .devcontainer/install-packages.sh into the course image, as the
# Codespace user so students can still add and update packages. The build
# workflow copies it in here first: a feature only sees its own folder.
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
