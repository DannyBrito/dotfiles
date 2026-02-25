#!/bin/sh
set -eu

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLS_FILE="$SCRIPT_DIR/tools.txt"

# Check for Homebrew
if ! command -v brew >/dev/null 2>&1; then
  echo "Homebrew not installed. Please install it first."
  exit 1
fi

# Disable auto-updates to avoid prompts
export HOMEBREW_NO_AUTO_UPDATE=1

echo "Processing tools..."

# Read from the file directly (avoids piping into while read)
while IFS= read -r pkg || [ -n "$pkg" ]; do
  # Trim whitespace
  pkg="$(printf '%s' "$pkg" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
  # Skip blank lines and comments
  [ -z "$pkg" ] && continue
  case "$pkg" in \#*) continue ;; esac

  # Handle casks with either "cask:name" or "--cask name" format.
  case "$pkg" in
    cask:*)
      cask_name="${pkg#cask:}"
      ;;
    --cask\ *)
      cask_name="${pkg#--cask }"
      ;;
    *)
      cask_name=""
      ;;
  esac

  if [ -n "$cask_name" ]; then
    cask_name="$(printf '%s' "$cask_name" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    if brew list --cask "$cask_name" >/dev/null 2>&1; then
      outdated_cask="$(brew outdated --cask "$cask_name" 2>/dev/null || true)"
      if [ -n "$outdated_cask" ]; then
        echo "Upgrading cask: $cask_name"
        brew upgrade --cask "$cask_name" </dev/null
      else
        echo "Cask $cask_name is already up to date"
      fi
    else
      echo "Installing cask: $cask_name"
      brew install --cask "$cask_name" </dev/null
    fi
  else
    # Handle normal formulae.
    if brew list --formula "$pkg" >/dev/null 2>&1; then
      outdated_formula="$(brew outdated --formula "$pkg" 2>/dev/null || true)"
      if [ -n "$outdated_formula" ]; then
        echo "Upgrading: $pkg"
        brew upgrade "$pkg" </dev/null
      else
        echo "$pkg is already up to date"
      fi
    else
      echo "Installing: $pkg"
      brew install "$pkg" </dev/null
    fi
  fi
done < "$TOOLS_FILE"

echo ""
echo "macOS tools installation complete"
