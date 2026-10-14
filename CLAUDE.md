# CLAUDE.md

Solo student repository for **BIL/COME 463 Compiler Design** (Fall 2026, Prof. Ammar Daşkın). Over the semester we build **one compiler** for a language we design ourselves, adding one phase per project: lexer → parser + AST → semantic analysis → IR + code generation. The student must be able to explain every line, so clarity beats cleverness.

## Start here

| Need | Read |
|---|---|
| What we are doing **right now** (milestone, deadline, checklist) | `docs/PLAN.md` |
| Where the last session stopped | the top entry of `docs/SESSION_LOG.md` |
| The assignment itself | `projects/project-N/directives/` |
| The big picture across the semester | `docs/ROADMAP.md` |

End every working session with **`/wrap-up`**. The repo is the only memory shared between sessions and cloud agents.

## Repository map

```
CLAUDE.md                    this file: orientation only
README.md                    human-facing intro (author, course)
.claude/
  rules/                     binding rules, loaded automatically (see index below)
  skills/wrap-up/            /wrap-up: end-of-session handoff
  settings.json              permissions (git write commands are denied)
docs/
  PLAN.md                    current milestone plan + decisions log   ← living
  SESSION_LOG.md             one entry per session, newest first      ← living
  AI_USAGE.md                AI prompts and mistakes, feeds reports   ← living
  LANGUAGE.md                our language spec, source of truth (to be written)
  ROADMAP.md                 semester overview and milestones
  lectures-notes/            course material (read-only)
projects/
  project-N/directives/      professor's assignment text, verbatim (read-only)
  project-N/solution/        per-submission docs: README, SPEC, REPORT, BPE scripts
src/                         the compiler; one codebase that grows each project
tests/                       test inputs + expected outputs (tests/<phase>/expected/)
Makefile                     build, test, package (to be written)
```

The code lives in `src/` and `tests/`, not inside `projects/`, because every project extends the previous one. A submission zip is assembled from them (`make package-pN`).

## Rules index (`.claude/rules/`)

| File | Covers |
|---|---|
| `workflow.md` | How to reply after a change (2–3 paragraph explanation) and git handling (show commands, never run them) |
| `course-policy.md` | Academic integrity, AI-usage logging, tutoring for handwritten parts, read-only folders |
| `docs-and-memory.md` | Which doc to update when, and the source-of-truth order |
| `c-flex.md` | C / Flex / Bison coding and testing standards (applies to `src/`, `tests/`, `Makefile`) |

## Stack and commands

- **C11 + Flex 2.6** (lexer), **Bison 3.x** from Homebrew for the parser (macOS ships 2.3, which is too old). Must also build with `gcc` on Linux.
- Python in `.venv/` only for side tools (tiktoken BPE comparison).
- Planned commands: `make` (build) · `make test` (golden-file tests) · `make package-p1` (submission zip).

## References

- Professor's repo, with newer lectures and example code: https://github.com/adaskin/compiler-course (for example `lecture-notes/3-lexer-minilang-example/flex/` and `lecture-notes/5-bison-example/`)
- Flex manual: https://westes.github.io/flex/manual/ · Thain, *Introduction to Compilers and Language Design* (free online)
