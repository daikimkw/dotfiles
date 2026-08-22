#!/bin/bash

# Install the herdr Claude Code integration hook.
# The hook script itself is NOT chezmoi-managed on purpose: herdr owns it and
# overwrites it on every version bump, so letting chezmoi hold a copy would
# revert herdr's updates. Instead this runs on every apply and lets herdr be
# the source of truth. The matching SessionStart entry in dot_claude/settings.json.tmpl
# is byte-identical to what herdr writes, so this call is a no-op once current.

set -eu

command -v herdr >/dev/null 2>&1 || exit 0

# Skip the reinstall when the integration is already at the current version.
if herdr integration status 2>/dev/null | grep -q '^claude: current'; then
  exit 0
fi

herdr integration install claude
