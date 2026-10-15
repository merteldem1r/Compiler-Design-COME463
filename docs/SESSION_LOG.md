# Session Log

Newest entry on top. One entry per working session, written by `/wrap-up`.

---

## 2026-10-15/16 — Lexer, tests, BPE, SPEC + REPORT, submission zip

**Done**
- Status analysis: found the directive's "Monday, October 20" is self-contradictory (Oct 20, 2026 is a Tuesday; class is Tue 09:30). Working deadline set to **Mon 2026-10-19**.
- Spec v0.2 with the student's decisions: floats may have leading zeros (`007.5`), `123abc` = `INT_LIT IDENT`, non-ASCII bytes reported in hex (allowed inside comments/strings), `END` = code 0, exact output format. Later fixes: counts corrected to 16 keywords / 13 multi-char operators; string regex excludes `\r`.
- `src/tokens.h`, `src/lexer.l`, `src/main.c`, `Makefile`: builds warning-free with clang and gcc-15.
- Tests: `tests/lexer/` 7 files, cases C1–C33, golden outputs reviewed line by line; `make test` 7/7.
- BPE: `.venv` + tiktoken 0.14.0, `projects/project-1/solution/bpe/bpe_compare.py` → `results.md` (`make bpe`). Key numbers: 459 lexer vs 1,681 BPE tokens (610 on lexemes only); Turkish 14 tokens / 3 words vs English 4 / 4; the lecture slide's `' 4','2'` for 42 does not match any measured encoding.
- `SPEC.pdf` (1 page), `REPORT.pdf` (2 pages), submission `README.md`; `make pdf-p1`, `make package-p1` → `dist/project1.zip`, dry-run from an empty folder: clang + gcc-15 warning-free, 7/7, BPE reproduces.
- Study material: `docs/study/p1-part-a-guide.md` (Part A method + practice, no graded answers) and `docs/study/p1-lexer-walkthrough.html` (every file explained, build flow, live playground checked against `ankac`).

**Bugs hit**
- #1 `-Wsign-compare` warning inside Flex-generated `lex.yy.c` (Apple Flex compares signed `int` with unsigned `yy_size_t`) → compile it separately with `-Wno-sign-compare`; `main.c` keeps all warnings.
- #2 `print("abc\` + newline gave two errors: `\\.` needs a char after `\` and `.` never matches `\n`, so the lone `\` hit the catch-all → unterminated rule ends in `\\?`. Test C32.
- #3 `\r\n` files: the invisible `\r` leaked into the unterminated-string error and scrambled the terminal → string class `[^"\\\r\n]`, escapes `\\[^\r\n]`. Test C33 (kept CRLF by `.gitattributes`). Bugs #2/#3 tests verified to fail on the old lexer.
- Doc bugs: spec said 15 keywords / 10 multi-char ops (really 16 / 13), caught via `YY_NUM_RULES 62`; SPEC decision 1 wording and report bug numbering corrected before packaging.

**Next**
1. Student reads and edits `projects/project-1/solution/REPORT.html` and `SPEC.html` (rewrite the 5 BPE answers in own words), then `make pdf-p1 && make package-p1`.
2. Student finishes Part A (guide: `docs/study/p1-part-a-guide.md`), scans to one PDF; asks the professor about deadline (Mon 19 vs Tue 20) and solo work.
3. Submit Part A PDF + `dist/project1.zip` by Mon 2026-10-19; `git tag p1-submission`; then update `ROADMAP.md` and rewrite `PLAN.md` for P2 (`brew install bison` first). Optional: Linux build check in Docker.

---

## 2026-10-14 — Status check, session recovery, wrap-up hook

**Done**
- Status analysis: P1 Part B is at "spec written, waiting for student review". No `src/`, `tests/`, `Makefile` or `.venv` yet; Part A not started. Flex 2.6.4 + gcc are installed. Homebrew Bison is **not** installed (only `/usr/bin/bison` 2.3), which matters for P2.
- Recovered the previous session (ended with `/exit`, no log) from its transcript: new `SESSION_LOG.md` entry, two `AI_USAGE.md` rows, verbatim prompts P-2–P-4.
- `docs/ROADMAP.md`: MiniLang → Anka.
- Added `.claude/hooks/check-wrap-up.sh` + a `SessionStart` (startup) hook in `.claude/settings.json`. It flags commits newer than the last `SESSION_LOG.md` commit, and uncommitted leftovers. Tested: it listed the 3 unlogged commits.
- `CLAUDE.md`: hook in the repo map; closing order `/wrap-up` → git block → `/exit`.

**Bugs hit**
- Process bug: the previous session's log was lost because `/exit` doesn't run `/wrap-up`. Skills only run when invoked, and the only hooks were Superset notifications. Fix: closing routine + detection hook.
- Spec issues found in review (not fixed yet, waiting for the student): the float regex accepts `007.5` while `007` is an error; `\\.` accepts any escape, so `\q` must be rejected in the C action.

**Next**
1. Student review of `docs/LANGUAGE.md`: decide on leading zeros in floats, confirm the smaller AI-made choices (`print` keyword, `007` error, no negative literals, `1.`/`.5` invalid, ASCII only).
2. Write `src/tokens.h`, `src/lexer.l`, `src/main.c`, `Makefile` (Thursday's plan).
3. Part A, A1 regexes on paper.

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
