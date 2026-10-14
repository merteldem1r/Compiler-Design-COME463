# Current Plan — Project 1: Lexical Analysis

> The working plan for the **current** milestone. When it ships, summarize it in `ROADMAP.md` and rewrite this file for the next milestone.

**Directive:** `projects/project-1/directives/p1.md` (copied verbatim from the professor's GitHub)
**Due: Monday, October 20, 2026, before class.** No late submissions.
**Submit on Google Classroom:** the Part A PDF and the Part B zip (which contains REPORT.pdf).
**Stack:** C + Flex (Path A). Solo. **Language:** Anka (`.anka`), spec in `docs/LANGUAGE.md`.

## What is being graded

| Part | What | Weight | Who does it |
|---|---|---|---|
| A | RE → NFA → DFA theory, **handwritten** and scanned to one PDF | 30% | You, on paper. Claude tutors and checks |
| B | Design our own language + Flex lexer + tests + BPE comparison + report | 60% | Together |
| Bonus | Regex → NFA → DFA visualizer (Python + graphviz) | +10% | Only if time is left |

Part B breakdown: spec 15, correct tokenization 15, maximal munch + keyword priority + error handling 10, test suite 10, report 10, BPE comparison 10.

## Schedule (6 days)

| Day | Part B (together) | Part A (you, ~1 h/day) |
|---|---|---|
| Wed 14 | Repo setup ✅ · language designed ✅ (`docs/LANGUAGE.md` v0.1) | A1 regexes |
| Thu 15 | Finish `docs/LANGUAGE.md` · write `src/lexer.l` + driver · Makefile | A2 automata |
| Fri 16 | Tests (≥3 files, ≥15 cases) + expected outputs · fix bugs (**log them for the report**) | A3 Thompson |
| Sat 17 | BPE comparison with tiktoken · draft REPORT.md + SPEC | A4 subset + minimization |
| Sun 18 | Export SPEC.pdf + REPORT.pdf · build zip · dry-run from a clean clone | A5 + scan to PDF |
| Mon 20 | **Submit before class** · `git tag p1-submission` | — |

## Checklist

### Part B: language and lexer
- [x] Official directive saved to `projects/project-1/directives/p1.md`
- [x] Repo structure, `CLAUDE.md`, session/AI logs, `/wrap-up` skill, git init
- [x] Language name + one-sentence purpose: **Anka**, a small statically typed C-like language
- [x] `docs/LANGUAGE.md`: token table (category → regex → example) covering **≥6 keywords, identifiers, int + float literals, ≥8 operators incl. multi-char (`==`, `<=`, `&&`), punctuation, `//` and `/* */` comments, a control structure, a loop**, plus 3 example programs (5–10 lines) and 2 design decisions with reasons
- [x] Design with M2–M4 in mind: `return`, functions, `{ }`, `;`, types, `true/false`, string literals
- [ ] Student review of `docs/LANGUAGE.md` (anything to change before we code?)
- [ ] `src/lexer.l`, `src/tokens.h`, `src/main.c`, `Makefile` (`make`, `make test`, `make package-p1`)
- [ ] Lexer handles: maximal munch, keyword priority, line numbers, errors (report line, skip, continue), multi-char operators, both comment kinds, unterminated `/*` at EOF
- [ ] Tests: `tests/lexer/` ≥3 files and ≥15 distinct cases (valid programs, edge cases, error cases) with `tests/lexer/expected/`
- [ ] Log every real bug we hit (the report needs **3 bugs**: what failed, why, how it was fixed)

### Part B: BPE comparison and report
- [ ] `.venv` + `pip install tiktoken`; script in `projects/project-1/solution/bpe/`
- [ ] Answer the 5 BPE questions (token counts, `42`, `@`, parser vs neural net, the Turkish sentence)
- [ ] `REPORT.md` → `REPORT.pdf` (2 pages: design / testing and bugs / AI usage + BPE). Must cover the input `ifx`
- [ ] `SPEC.md` → `SPEC.pdf` (1 page)
- [ ] Submission `README.md`: author, path, build instructions, AI tools used
- [ ] Zip layout: `project1/{README.md, SPEC.pdf, src/, tests/, output/, REPORT.pdf}`

### Part A (handwritten, individual)
- [ ] A1 regexes (15) · [ ] A2 automata (15) · [ ] A3 Thompson (10) · [ ] A4 subset + minimization (15) · [ ] A5 short answers (5)
- [ ] Scan everything to one PDF with name and student ID on every page

## Open questions
- [ ] The assignment says groups of 2–3 (the FAQ says 2 is fine). **Confirm solo is OK** with the professor on Classroom.
- [ ] Bonus: decide on Sat 17 based on time left.

## Decisions log

| Date | Decision | Why |
|---|---|---|
| 2026-10-14 | Path A: C + Flex | The lectures and examples are Flex-first, C is a prerequisite, and it leads naturally into Bison for M2 |
| 2026-10-14 | Compiler code in root `src/` and `tests/`, not per project | P2–P4 extend the same lexer. Each submission zip is assembled by `make package-pN` |
| 2026-10-14 | The repo is the agent memory (`PLAN.md`, `SESSION_LOG.md`, `AI_USAGE.md`) | Solo, multi-session, and cloud agents only see committed files |
| 2026-10-14 | `CLAUDE.md` is a short orientation map; all rules live in `.claude/rules/` | One place per concern; `CLAUDE.md` stays short and doesn't drift from the rules |
| 2026-10-14 | The agent never runs git write commands; it shows them and the student runs them | The student keeps full control of history (also enforced in `.claude/settings.json`) |
| 2026-10-14 | Language **Anka** (`.anka`): C-like, `x: int` annotations, braces + `;`, `->` `..` `**`, compound assignment, `%`, `break`/`continue`, `for i in a..b` | Chosen together via Q&A. Each feature is cheap in P2–P4; see `docs/LANGUAGE.md` §6 |
| 2026-10-14 | Strings only as `print` arguments; comments nest | Full lexer edge cases without string memory management in P4; nesting is a strong "beyond regular" report point |
| 2026-10-14 | Close every session with `/wrap-up` → student runs the git block → `/exit`; a `SessionStart` hook flags sessions that skipped it | A session ended with `/exit` and its log was lost. Hooks run shell commands, not the agent, so they can only *detect* a missed wrap-up, not write it |
