---
name: wrap-up
description: End-of-session handoff for this compiler course repo. Updates docs/SESSION_LOG.md, docs/PLAN.md checkboxes and decisions, docs/AI_USAGE.md, runs tests, and commits. Use when the user says wrap up, end session, save progress, or "we're done for today".
---

# Wrap-up: session handoff

Make sure the next session (local or cloud) can continue without this conversation.

1. **Tests**: if a `Makefile` with a `test` target exists, run `make test` and note the result. Never record failing tests as passing.
2. **`docs/PLAN.md`**: tick completed checklist items, add new tasks we discovered, and append any decision made this session to the decisions log (date, decision, why).
3. **`docs/SESSION_LOG.md`**: add a new entry **at the top** with today's date and a short title:
   - **Done**: concrete outcomes (files, features, tests)
   - **Bugs hit**: what failed, why, and the fix (the P1 report needs 3 of these, so don't skip this)
   - **Next**: the 1–3 most important next actions, specific enough to start cold
4. **`docs/AI_USAGE.md`**: add a row for this session. Copy 1–2 notable user prompts verbatim and record anything the AI got wrong and how it was fixed.
5. **`docs/LANGUAGE.md`**: if token or grammar rules changed in code, make sure the spec matches.
6. **Commit**: `git add -A` and commit with a message summarizing the session. Show the user `git status` and the commit hash. Don't push unless asked.
7. Tell the user in 3–5 lines what was saved and what's next.
