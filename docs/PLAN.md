# Current Plan — Project 1: Lexical Analysis

> The working plan for the **current** milestone. When it ships, summarize it in `ROADMAP.md` and rewrite this file for the next milestone.

**Directive:** `projects/project-1/directives/p1.md` (copied verbatim from the professor's GitHub)
**Due: before class on 2026-10-20 (class is Tuesday 09:30).** The directive says "Monday, October 20", but Oct 20, 2026 is a **Tuesday**. Until the professor confirms, we treat **Mon 2026-10-19** as the working deadline. No late submissions.
**Submit on Google Classroom:** the Part A PDF and the Part B zip (which contains REPORT.pdf).
**Stack:** C + Flex (Path A). Solo. **Language:** Anka (`.anka`), spec in `docs/LANGUAGE.md`.

## What is being graded

| Part | What | Weight | Who does it |
|---|---|---|---|
| A | RE → NFA → DFA theory, **handwritten** and scanned to one PDF | 30% | You, on paper. Claude tutors and checks |
| B | Design our own language + Flex lexer + tests + BPE comparison + report | 60% | Together |
| Bonus | Regex → NFA → DFA visualizer (Python + graphviz) | +10% | Only if time is left |

Part B breakdown: spec 15, correct tokenization 15, maximal munch + keyword priority + error handling 10, test suite 10, report 10, BPE comparison 10.

## Schedule (revised 2026-10-15)

Part A study guide: `docs/study/p1-part-a-guide.md`.

| Day | Part B (together) | Part A (you, ~1.5 h/day) |
|---|---|---|
| Wed 14 | Repo setup ✅ · language designed ✅ (`docs/LANGUAGE.md` v0.1) | (slipped) |
| Thu 15 | Spec review ✅ (v0.2) · lexer + driver + Makefile ✅ · tests ✅ (pulled forward) | A1 regexes |
| Fri 16 | BPE ✅ · SPEC.pdf + REPORT.pdf drafted ✅ · zip built + dry-run ✅ (all pulled forward) | A2 automata + A3 Thompson |
| Sat 17 | **Student reviews/edits REPORT + SPEC** (`make pdf-p1 && make package-p1`) · optional Linux check | A4 subset + minimization |
| Sun 18 | Buffer | A5 + scan to PDF |
| Mon 19 | **Submit** (working deadline) · `git tag p1-submission` | — |
| Tue 20 | Buffer only if the professor confirms Tue 09:30 | — |

## Checklist

### Part B: language and lexer
- [x] Official directive saved to `projects/project-1/directives/p1.md`
- [x] Repo structure, `CLAUDE.md`, session/AI logs, `/wrap-up` skill, git init
- [x] Language name + one-sentence purpose: **Anka**, a small statically typed C-like language
- [x] `docs/LANGUAGE.md`: token table (category → regex → example) covering **≥6 keywords, identifiers, int + float literals, ≥8 operators incl. multi-char (`==`, `<=`, `&&`), punctuation, `//` and `/* */` comments, a control structure, a loop**, plus 3 example programs (5–10 lines) and 2 design decisions with reasons
- [x] Design with M2–M4 in mind: `return`, functions, `{ }`, `;`, types, `true/false`, string literals
- [x] Student review of `docs/LANGUAGE.md` → v0.2 (2026-10-15)
  - [x] Leading zeros in floats: **allowed** (`007.5` is a float), like Python 3
  - [x] `123abc` stays `INT_LIT IDENT` (parser rejects it in P2); covered by a test
  - [x] Confirmed: `print` keyword, `007` error, no negative literals, `1.`/`.5` invalid, ASCII only (non-ASCII bytes reported in hex)
- [x] `src/lexer.l`, `src/tokens.h`, `src/main.c`, `Makefile` (`make`, `make test`) — builds warning-free with clang and gcc-15 (2026-10-15)
- [x] `make package-p1` → `dist/project1.zip`; unzipped in an empty folder: builds warning-free (clang, gcc-15), 7/7 tests, BPE reproduces (2026-10-16)
- [x] Lexer handles: maximal munch, keyword priority, line numbers, errors (report line, skip, continue), multi-char operators, both comment kinds, unterminated `/*` at EOF
- [x] Tests: `tests/lexer/` 7 files, 33 cases C1–C33 (valid programs, edge cases, error cases) with `tests/lexer/expected/`; `make test` 7/7 pass (2026-10-15)
- [x] Log every real bug we hit (the report needs **3 bugs**: what failed, why, how it was fixed). 3 logged below

### Part B: BPE comparison and report
- [x] `.venv` + tiktoken 0.14.0; `bpe_compare.py` → `results.md`; `make bpe` regenerates it (2026-10-16)
- [x] Answer the 5 BPE questions (token counts, `42`, `@`, parser vs neural net, the Turkish sentence): AI draft in REPORT §3, **student to review/rewrite**
- [x] `REPORT.html` → `REPORT.pdf` (2 pages: design / testing and bugs / AI usage + BPE, covers `ifx`), `make pdf-p1`. **Student must read and edit before submitting**
- [x] `SPEC.html` → `SPEC.pdf` (1 page)
- [x] Submission `README.md`: author, path, build instructions, AI tools used
- [x] Zip layout: `project1/{README.md, SPEC.pdf, src/, tests/, output/, REPORT.pdf}` (+ `Makefile`, `bpe/`)
- [ ] Optional: Linux build check in Docker (needs Docker Desktop running)
- [ ] **Student: read and edit REPORT.html / SPEC.html** (BPE answers in own words), then `make pdf-p1 && make package-p1`
- [ ] Submit Part A PDF + `dist/project1.zip` on Classroom · `git tag p1-submission` · then update ROADMAP and rewrite this PLAN for P2

### Part A (handwritten, individual)
- [ ] A1 regexes (15) · [ ] A2 automata (15) · [ ] A3 Thompson (10) · [ ] A4 subset + minimization (15) · [ ] A5 short answers (5)
- [ ] Scan everything to one PDF with name and student ID on every page

## Bugs log (raw material for REPORT §2)

| Date | What failed | Why | Fix |
|---|---|---|---|
| 2026-10-15 | **#2** `print("abc\` + newline gave two errors: "unterminated string" and "unexpected character '\\'" | The escape part `\\.` needs a character after `\`, and `.` never matches `\n`, so the regex stopped before the lone `\` and the catch-all reported it | Unterminated rule ends with `\\?` (optional lone backslash). Test: `strings_comments.anka` C32 |
| 2026-10-15 | **#3** In a Windows (`\r\n`) file, an unterminated string's error text contained an invisible `\r` that scrambled the terminal output | `[^"\\\n]` excluded `\n` but not `\r` | Exclude `\r` too: `[^"\\\r\n]` and escapes `\\[^\r\n]`. Test: `crlf_line_endings.anka` C33 (kept as CRLF by `.gitattributes`) |
| 2026-10-15 | **#1** `make` printed a `-Wsign-compare` warning in `build/lex.yy.c` | Apple's Flex 2.6.4 generates code comparing a signed `int` with an unsigned `yy_size_t`; our `-Wextra` catches it. Not our code, so we can't fix the line | Compile the generated file separately with `-Wno-sign-compare`; `main.c` keeps all warnings |

## Open questions
- [ ] **Ask the professor on Classroom (one message):** (1) is the deadline Mon Oct 19 or Tue Oct 20 before class? (2) is working solo OK? (the assignment says groups of 2–3; the FAQ says 2 is fine)
- [ ] Bonus: decide on Sat 17 based on time left.
- [ ] Before P2: `brew install bison` (macOS `/usr/bin/bison` is 2.3, too old).

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
| 2026-10-15 | Floats may have leading zeros; `123abc` is `INT_LIT IDENT`; non-ASCII bytes reported in hex (spec v0.2) | Python 3 precedent: the int ban exists because C reads `007` as octal, floats never had that meaning. `123abc` is a syntax problem the parser catches, so the lexer stays simple |
| 2026-10-15 | Tests: 7 files, numbered cases C1–C33; expected outputs checked line by line, not just generated | A golden file only proves something if a human checked it; numbered cases let the report cite exact tests |
| 2026-10-16 | SPEC and REPORT written as HTML and printed to PDF by headless Chrome (`make pdf-p1`) | No pandoc on this Mac; HTML gives exact control to fit the 1- and 2-page limits |
| 2026-10-16 | Zip also contains `Makefile` and `bpe/`; folder paths are Makefile variables (`TEST_DIR`, `EXPECTED_DIR`, `BPE_DIR`) | The assignment's layout (`tests/` + `output/`) differs from the repo's; one Makefile serves both, so the grader can `make test` |
| 2026-10-16 | BPE table adds a "lexemes only" column | Separates "BPE also counts comments/whitespace" from "BPE cuts differently" (1,681 vs 610 vs 459 tokens) |
| 2026-10-15 | Working deadline Mon 2026-10-19 | The directive's "Monday, October 20" is self-contradictory (Oct 20 is a Tuesday, the class day). Aim for the earlier date until confirmed |
| 2026-10-14 | Close every session with `/wrap-up` → student runs the git block → `/exit`; a `SessionStart` hook flags sessions that skipped it | A session ended with `/exit` and its log was lost. Hooks run shell commands, not the agent, so they can only *detect* a missed wrap-up, not write it |
