#!/bin/sh
# SessionStart hook: warn the agent when the previous session ended without /wrap-up.
# Whatever this script prints is added to the agent's context at the start of a session.
# It prints nothing when everything looks logged.

cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

# 1. Work was committed after the last committed session-log entry.
last_commit=$(git log -1 --format=%ct 2>/dev/null)
last_log=$(git log -1 --format=%ct -- docs/SESSION_LOG.md 2>/dev/null)
if [ -n "$last_commit" ] && [ "${last_log:-0}" -lt "$last_commit" ]; then
  echo "WRAP-UP CHECK: there are commits newer than the last committed docs/SESSION_LOG.md entry:"
  git log --oneline "$(git log -1 --format=%H -- docs/SESSION_LOG.md)..HEAD" 2>/dev/null
  echo "The previous session probably ended without /wrap-up. Tell the student first thing, and offer to"
  echo "rebuild the missing SESSION_LOG.md / AI_USAGE.md entries from those commits (and, on the student's"
  echo "machine, from the session transcript in ~/.claude/projects/)."
fi

# 2. Uncommitted changes are left over from the previous session.
if [ -n "$(git status --porcelain)" ]; then
  if git status --porcelain -- docs/SESSION_LOG.md | grep -q .; then
    echo "WRAP-UP CHECK: /wrap-up ran but its changes are not committed yet. Remind the student to run the git block."
  else
    echo "WRAP-UP CHECK: uncommitted changes exist and docs/SESSION_LOG.md was not updated:"
    git status --short
    echo "Tell the student, and offer to run /wrap-up for that work."
  fi
fi
exit 0
