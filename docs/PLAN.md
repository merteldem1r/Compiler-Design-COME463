# Current Plan — Project 1: Lexical Analysis (Milestone 1)

> This is the working plan for the **current** milestone. When a milestone ships, move its summary to `ROADMAP.md` and rewrite this file for the next one.

## What Project 1 asks (from lectures 3 and 4)

The directive file `projects/p1-lexical-analysis/directives/p1-lexical-analysis.md` is still **empty**. Until the official text is pasted there, this is what the slides say:

> **Project-1: Specifying a PL (using flex)**
> 1. Specify rules for identifiers, keywords, etc. for a programming language
> 2. Write regular expressions for each of them
> 3. Use flex (or similar) to tokenize a given input file

Minimum token set ("All paths must recognize some form of"):

| Category | Examples |
|---|---|
| Numbers | `123`, `45.67` |
| Identifiers | `variable`, `calculate_sum` |
| Keywords | `let`, `def`, `if`, `else` |
| Operators | `+ - * /` |
| Punctuation | `( ) = ,` |

Tests the slides explicitly expect to pass:

```
let x = 5        → LET ID(x) EQ NUMBER(5)
identifier       → one ID (maximal munch, not "ident if ier")
if / ifcondition → KEYWORD_IF / IDENTIFIER
let x@y = 5      → LET ID(x) ID(y) EQ NUMBER(5) plus an error for '@' (skip and continue)
```

Expected output style (from the `minilang.l` demo): `LINE 1: KEYWORD 'let'`, with line numbers.

## Open questions (need answers before we finalize)

- [ ] Paste the official P1 directive: deadline, submission format (Classroom? GitHub?), report requirements
- [ ] Implementation path: **A (C + Flex/Bison)**, B (Python + PLY), or C (OCaml)?
- [ ] Solo or group (2–3 people)?
- [ ] AI extension: decide early, because a tensor DSL would add tokens now (`tensor`, `matmul`, `[`, `]`)

## Steps

1. [ ] **Design the language**: write `docs/LANGUAGE.md` with the full token table (category, regex, example, notes). Plan for M2–M4 now: comparison ops (`== != < <= > >=`), `while`, `return`, `{ }`, `;`, comments, string literals, `true/false`, types (`int`, `float`, `bool`).
2. [ ] **Set up the toolchain**: `brew install bison` (macOS ships Bison 2.3 from 2006; we need 3.x for M2), a `Makefile`, `git init`, and a private GitHub repo.
3. [ ] **Write the scanner**: `src/lexer.l` + `src/tokens.h` + `src/main.c` (driver that prints tokens).
   - Keywords before the identifier rule (rule priority)
   - Longest operators work automatically by maximal munch (`==` vs `=`, `<=` vs `<`)
   - Track line (and column) numbers
   - A last catch-all `.` rule reports `LINE n: ERROR: unexpected '@'` and continues
   - Comments and whitespace are skipped
4. [ ] **Tests**: `tests/lexer/*.mini` + `*.expected`, and `make test` runs a diff. Cover every token, every edge case above, the empty file, and an unterminated comment/string.
5. [ ] **Report** (`projects/p1-lexical-analysis/solution/REPORT.md`): token table with regexes, design decisions (priority, maximal munch, error strategy), sample runs, and an AI-usage acknowledgement.
6. [ ] **Exam prep for this milestone**: for 2–3 of our regexes (identifier, number, comment), draw the Thompson NFA, then the subset-construction DFA, then the minimized DFA.
7. [ ] **Optional extra credit in the spirit of the course**: run the same input through `tiktoken` and compare token counts (the "hands-on" slide in lecture 3).
8. [ ] Submit, then `git tag p1-submission`.

## Decisions log

| Date | Decision | Why |
|---|---|---|
| 2026-10-14 | Roadmap and plan written; stack still pending | First repo analysis |
