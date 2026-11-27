# Session Log

Newest entry on top. One entry per working session, written by `/wrap-up`.

---

## 2026-11-27 — Final project kickoff: analysis, repo reorg, CI, spec v1.0

**Done**
- Analyzed the final-project directive against the repo. Finding: only the P1 lexer exists, and Anka v0.2 (C-like, loops, mutation, floats, strings) conflicts with the required functional, expression-based language. Decision: **evolve this repo, don't restart**. Keep the name Anka and the lexer structure, and redesign the grammar as v1.0.
- Student decisions: P1 submitted; solo confirmed; demo **Tue 2026-12-15**; **C-style calls `f(x, y)`**; `.fpl` + `fplc`.
- Toolchain: student ran `brew install bison llvm` → Bison 3.8.2, LLVM/clang 23.1.6 (both keg-only). Checked with a hand-written `fact.ll` + C runtime: `opt -passes=verify` OK, clang links it, prints `120`.
- Repo reorganized: P1 code + 34-case tests frozen in `projects/project-1/code/` (own Makefile, still 8/8 PASS, CRLF test file kept via `.gitattributes`); `docs/study/` → `projects/project-1/study/`; `docs/LANGUAGE.md` v0.2 → `projects/project-1/LANGUAGE-v0.2.md`; directive → `projects/final-project/directives/`. New root `Makefile` builds `build/fplc` warning-free and finds the Homebrew tools (`make tools`).
- Rewrote `docs/PLAN.md` (final-project schedule, checklist per phase, decisions) and `docs/ROADMAP.md`; updated `CLAUDE.md`, `.claude/rules/c-flex.md` (diagnostics, Bison, LLVM, new test layout), `docs-and-memory.md`, the `/wrap-up` skill.
- Drafted `docs/LANGUAGE.md` **v1.0** (functional Anka): 11 keywords, 16 operators (15 after the review removed `%`), EBNF grammar, precedence table, type rules, scopes/capture, semantics (wrapping, `INT_MIN / -1`, div-by-zero), CLI, diagnostic catalog, AST dump format, 6 example programs with hand-computed output, 6 design decisions, §12 review checklist. Grammar checked in Bison before writing it.
- `.githooks/commit-msg` (type prefix, ≤ 72 chars, no period, imperative, blank line 2), `make hooks`, and `.github/workflows/ci.yml` (commit-message job + gcc/clang `-Werror` build matrix + P1 tests + `run_tests.sh` when present). Hook tested on 13 sample messages and the real history; both compilers build with `-Werror` locally.
- **Spec review with the student → `docs/LANGUAGE.md` v1.0 final.** Accepted: main's result ignored, print returns 0, multi-parameter `fun`, optional `let` annotation, one comparison level, big literals are lexer errors, runtime error format, `--check`/`--tokens`, indented AST. Changed: **`%` and nested comments removed**, `!` kept. Examples 4 and 5 rewritten (5 now uses a `rem` helper), outputs recomputed by hand.
- Commit rule: no `Co-Authored-By` trailers from now on (student's request; `.claude/rules/workflow.md`). Three pushed commits keep theirs; the student chose not to rewrite history.
- Rewrote root `README.md`: what Anka/`fplc` is, a code sample, the pipeline in plain words, a status table, requirements (macOS + Ubuntu), build/run (current `--tokens` vs the planned CLI), tests, repository structure, workflow, credits.
- README redesigned: centered header with CI and tool badges, an at-a-glance table, a narrow vertical text diagram for the pipeline (the old one-line diagram overflowed on GitHub), a stage table with the matching `fplc` flag, collapsible install steps, GitHub note boxes. A Mermaid flowchart + timeline were tried first; the student found them too much, so they were replaced by plain text.
- New rule: **no emojis** in any file or commit (`.claude/rules/docs-and-memory.md`). Removed them from README, PLAN, ROADMAP and the P1 study notes; read-only lecture notes and directives stay verbatim.
- Student enabled `make hooks` and pushed; CI is green on Ubuntu 24.04 (gcc + clang `-Werror`, P1 8/8; the runner has Flex 2.6.4, Bison 3.8.2, **LLVM 18.1.3**). Wrap-up check: root build `-Werror` OK, P1 snapshot 8/8; no `run_tests.sh` yet.
- Found: the GitHub repo is **PUBLIC**, against course policy. Still public at wrap-up; the student must make it private (`gh repo edit … --visibility private`).

**Bugs hit**
- Spec bug: the directive's `{ def } expr` program shape gives 3 shift/reduce conflicts with C-style calls (`(` and `-` after a function body). Fixed by requiring `fn main() -> int`; 0 conflicts.
- Draft errors caught by re-checking by hand before saving: example 6's column (said 20, really 16, verified with `awk index`); the 2-char operator count (said 6, really 7).
- Tooling: LLVM 23 rejects the directive's `opt -verify` ("the `opt -passname` syntax … is not supported"). Use `opt -passes=verify -disable-output`.
- CI: run 46038832325 (commit `a9cfaa7`) failed in the **gcc** job's install step, before any of our code ran. `packages.microsoft.com`, a third-party apt source preinstalled on GitHub's Ubuntu image, answered `403 Forbidden`, so `apt-get update` exited 100 although the Ubuntu lists had downloaded; the clang job on another machine passed. Fix: `apt-get update` only warns, and `apt-get install` still fails the job if a package is really missing. Also bumped `actions/checkout@v4` → `@v5` (Node 20 deprecation warning; v5 runs on Node 24).
- Tooling, open: clang warns `overriding the module target triple … [-Woverride-module]` when linking our `.ll`. To be decided in Phase 3.

**Next**
1. **Student: make the repo private** (`gh repo edit merteldem1r/Compiler-Design-COME463 --visibility private --accept-visibility-change-consequences`).
2. Write `SPEC.md` v1 (≤ 2 pages) from `docs/LANGUAGE.md` v1.0; keep it as the LLM experiment baseline.
3. Walking skeleton: `print_int(42)` through lexer → parser → AST → checker → `.ll` → clang → `42`. Then Phase 1: lexer update with columns, `parser.y`, AST, `--emit-ast`, recovery, tests.

---

## 2026-11-25 — Final project directive saved *(recovered)*

> No agent session; rebuilt on 2026-11-27 from commit `1f1c96d`.

**Done**
- The student saved the professor's final-project text as `projects/final-project/final_project.md` (moved to `directives/` on 2026-11-27).

**Next**
1. Analyze the directive and plan the final project.

---

## 2026-10-16 — P1 report in plainer words, own test C34 *(recovered)*

> The session ended without `/wrap-up`; rebuilt on 2026-11-27 from commits `1fb7bd0`, `0877691` and the matching `AI_USAGE.md` row.

**Done**
- The student wrote their own test program `tests/lexer/my_anka_code.anka` (`1fb7bd0`). The AI added its case header and hand-checked expected output as **C34** (nested `))`, no final newline): 8 files, 34 cases, 8/8 PASS.
- `REPORT.html` rewritten in plainer first-person language, still 2 pages; BPE results regenerated (512 vs 1,810 tokens); counts updated in README / PLAN / walkthrough.
- P1 was then submitted (student confirmed on 2026-11-27).

**Bugs hit**
- `1fb7bd0` added a test without an expected file, so `make test` and therefore `make package-p1` failed, and the report's BPE numbers were stale. Fixed by adding `expected/my_anka_code.out`.
- The first plain-language rewrite was 4 pages; trimmed to 2, checked by rendering the PDF.

**Next**
1. Submit P1 (done).

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
