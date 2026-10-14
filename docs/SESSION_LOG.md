# Session Log

Newest entry on top. One entry per working session, written by `/wrap-up`.

---

## 2026-10-14 — Repo rules + Anka language design *(recovered)*

> The session ended with `/exit`, not `/wrap-up`, so this entry was rebuilt afterwards from the session transcript and the commits `fd35f9a`, `f668548`, `8281c2b`.

**Done**
- Wrote the student's working rules into `.claude/rules/workflow.md`: explain every change in 2–3 paragraphs, and show git commands without running them. Added `.claude/settings.json`, which denies `git add/commit/push/tag` as a hard guard.
- Restructured `CLAUDE.md` into a short repo map and split the rules into four files (`workflow`, `course-policy`, `docs-and-memory`, `c-flex`). `c-flex.md` only loads when an agent works on `src/`, `tests/` or the `Makefile`.
- Designed the language together through multiple-choice questions: **Anka** (`.anka`), C-like, `x: int` annotations, braces + `;`, `->` `..` `**`, compound assignment, `%`, `break`/`continue`, `for i in a..b`, strings only in `print`, nesting comments.
- Wrote `docs/LANGUAGE.md` v0.1: 15 keywords, 22 operators (10 multi-char), token table with regexes, error table, lexer traps, output format, 3 example programs, 5 design decisions.

**Bugs hit**
- No code yet. A spec inconsistency was found in the next session: `007` is an error, but the float regex accepts `007.5`. It waits for the student's spec review.

**Next**
1. Student review of `docs/LANGUAGE.md`, including the leading-zero float question and invalid escapes (checked in the C action, not the regex).
2. Write `src/tokens.h`, `src/lexer.l`, `src/main.c`, `Makefile`.
3. Part A, A1 regexes on paper.

---

## 2026-10-14 — Repo analysis and setup

**Done**
- Read every lecture note (1–5) and the syllabus. Wrote `docs/ROADMAP.md`.
- Found the official P1 directive in the professor's repo (`adaskin/compiler-course/projects/project1.md`) and saved it to `projects/project-1/directives/p1.md`. **Due Mon 2026-10-20.**
- Chose Path A (C + Flex), solo.
- Created `CLAUDE.md`, `docs/PLAN.md` (6-day schedule), `docs/SESSION_LOG.md`, `docs/AI_USAGE.md`, the `/wrap-up` skill, `.gitignore`, and ran `git init`.

**Decisions**: see the decisions log in `docs/PLAN.md`.

**Next**
1. Pick the language name and purpose, then draft the token table in `docs/LANGUAGE.md`.
2. Start Part A (A1 regexes) on paper.
3. Ask the professor whether solo is OK.
