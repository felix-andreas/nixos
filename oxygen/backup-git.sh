#!/usr/bin/env bash
# Generic git backup script: auto-commit and push a local repo to a remote.
# Can also be run standalone.
#
# Usage: backup-git <path>

set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: backup-git <path>"
  exit 1
fi

REPO_DIR="$1"
REPO_NAME=$(basename "$REPO_DIR")

# Default to critical — if any command fails, the trap fires with
# whatever message was last set, so we always get a desktop notification.
title="Failed to backup $REPO_NAME"
body="unknown error"
urgency="critical"

cleanup() {
  notify-send -u "$urgency" "$title" "$body"
}
trap cleanup EXIT

# Run a command, capturing its output. If it fails, include the
# actual error message in the notification and exit.
run() {
  local label="$1"
  shift
  local output
  if ! output=$("$@" 2>&1); then
    body=$(printf "error: %s\n%s" "$label" "$output")
    exit 1
  fi
}

# Repo must already exist
if [[ ! -d "$REPO_DIR/.git" ]]; then
  body=$(printf "error: %s is not a git repository" "$REPO_DIR")
  exit 1
fi

cd "$REPO_DIR"

# Pull remote changes first (in case of edits via web UI)
run "git pull failed" git pull

# Stage everything
run "git add failed" git add --all

# Nothing to do — exit early with a quiet notification
if git diff --cached --quiet; then
  title="No changes in $REPO_NAME"
  body="Nothing to back up"
  urgency="low"
  exit 0
fi

# Commit and push
run "git commit failed" git commit -m "backup: $(date +%Y-%m-%d)"
run "git push failed" git push

# If we got here, everything worked
summary=$(git diff --stat HEAD~1)
title="Pushed backup for $REPO_NAME"
body="$summary"
urgency="normal"
