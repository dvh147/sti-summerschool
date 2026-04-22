#!/usr/bin/env bash
# Stop hook: nudge Claude to update CLAUDE.md when the session made changes
# to other files but left CLAUDE.md untouched.
#
# Never blocks stopping — exit 0 always. Prints a reminder to stderr so
# Claude sees it in the transcript.

set -u
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0

status=$(git status --porcelain 2>/dev/null || true)
[ -z "$status" ] && exit 0

# Is anything changed besides CLAUDE.md?
other=$(printf '%s\n' "$status" | grep -v 'CLAUDE\.md$' || true)
# Is CLAUDE.md itself in the change set?
claude_md=$(printf '%s\n' "$status" | grep 'CLAUDE\.md$' || true)

if [ -n "$other" ] && [ -z "$claude_md" ]; then
  echo "Reminder: this session changed project files but not CLAUDE.md. If any plan or state changed, update CLAUDE.md before finishing." >&2
fi

exit 0
