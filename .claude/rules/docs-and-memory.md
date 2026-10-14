# Docs and memory

Sessions don't share memory, but the repo does. Keep these files current so any session, local or cloud, can continue cold.

## Source of truth, in priority order
1. `projects/project-N/directives/`: what the professor requires. Wins every conflict.
2. `docs/LANGUAGE.md`: what our language is (tokens, grammar, types). Code must match it.
3. `docs/PLAN.md`: what we are doing now and the decisions already made. Don't reopen a logged decision without a reason.
4. Everything else.

## What to update, and when

| File | Update when | Content |
|---|---|---|
| `docs/PLAN.md` | A task finishes, a task is discovered, or a decision is made | Checklist ticks; decisions log row (date, decision, why) |
| `docs/SESSION_LOG.md` | End of every session (`/wrap-up`) | New entry **on top**: Done / Bugs hit / Next |
| `docs/AI_USAGE.md` | A notable prompt, or the AI got something wrong | Table row + verbatim prompt |
| `docs/LANGUAGE.md` | **Before** changing token or grammar rules in `src/` | Spec first, then code |
| `docs/ROADMAP.md` | A milestone ships or the semester plan changes | Milestone status |

## Conventions
- Dates are absolute (`2026-10-14`), never "yesterday" or "next week".
- **Bugs hit** entries matter: project reports require concrete bugs (what failed, why, fix).
- When a milestone is submitted, summarize it in `ROADMAP.md` and rewrite `PLAN.md` for the next milestone.
