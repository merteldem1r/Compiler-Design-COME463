# CLAUDE.md

Solo student repository for **BIL/COME 463 Compiler Design** (Fall 2026, Prof. Ammar Daşkın). The current work is the **final project**: `fplc`, a compiler for **Anka**, our own small functional language (`.fpl`). It parses, type checks, and emits LLVM IR. It grows from the Project 1 lexer. The student must be able to explain every line live, so clarity beats cleverness.

## Start here

| Need | Read |
|---|---|
| What we are doing **right now** (phase, deadline, checklist) | `docs/PLAN.md` |
| Where the last session stopped | the top entry of `docs/SESSION_LOG.md` |
| The assignment itself | `projects/final-project/directives/final_project.md` |
| The language | `docs/LANGUAGE.md` (source of truth) → `SPEC.md` (2-page deliverable) |
| The big picture | `docs/ROADMAP.md` |

End every working session with **`/wrap-up`**, then the student runs the printed git block, then `/exit`. The repo is the only memory shared between sessions and cloud agents. If a session starts with a `WRAP-UP CHECK` note, raise it with the student before anything else.

## Repository map

The root mirrors the final-project deliverable (`README.md`, `SPEC.md`, `src/`, `runtime.c`, `tests/`, `examples/`, `run_tests.sh`, `REPORT.pdf`); files appear as each phase adds them.

```
CLAUDE.md                    this file: orientation only
README.md                    human-facing intro; becomes the deliverable README (author, path, LLVM version, build/run)
Makefile                     make · make tools · make hooks · make clean (grows each phase)
.githooks/commit-msg         commit-message check (type prefix, ≤ 72 chars, imperative); enable with `make hooks`
.github/workflows/ci.yml     CI on push/PR: commit messages, gcc + clang -Werror build, P1 tests, run_tests.sh
src/                         the compiler: lexer.l now; parser.y, ast, check, codegen, main.c to come
tests/                       (to come) valid/ errors/ recovery/: X.fpl + X.expected
.claude/
  rules/                     binding rules, loaded automatically (see index below)
  skills/wrap-up/            /wrap-up: end-of-session handoff
  hooks/check-wrap-up.sh     on startup, flags a previous session that skipped /wrap-up
  settings.json              permissions (git write commands are denied) + hooks
docs/
  PLAN.md                    current plan + decisions log            ← living
  SESSION_LOG.md             one entry per session, newest first     ← living
  AI_USAGE.md                AI prompts and mistakes, feeds reports  ← living
  LANGUAGE.md                Anka v1.0 spec, source of truth (being written)
  ROADMAP.md                 semester overview and milestones
  lectures-notes/            course material (read-only)
projects/
  project-1/                 FROZEN, submitted: directives/, solution/ (SPEC, REPORT, BPE),
                             code/ (buildable lexer snapshot + 34-case tests), study/, LANGUAGE-v0.2.md
  final-project/directives/  the professor's final-project text (read-only)
  final-project/solution/    (to come) report sources, LLM experiment, BPE scripts
```

## Rules index (`.claude/rules/`)

| File | Covers |
|---|---|
| `workflow.md` | How to reply after a change (2–3 paragraph explanation) and git handling (show commands, never run them) |
| `course-policy.md` | Academic integrity, AI-usage logging, tutoring for handwritten parts, read-only folders |
| `docs-and-memory.md` | Which doc to update when, and the source-of-truth order |
| `c-flex.md` | C / Flex / Bison / LLVM IR coding and testing standards (applies to `src/`, `tests/`, `Makefile`) |

## Stack and commands

- **C11 + Flex 2.6 + Bison 3.8 (Homebrew)**, emitting LLVM IR as text; **LLVM/clang 23 (Homebrew)** for `opt` and linking. Both Homebrew packages are keg-only (not on PATH); the Makefile finds them under `/opt/homebrew/opt/`. Must also build with `gcc` on Linux.
- Verify IR with `opt -passes=verify -disable-output x.ll` (LLVM 23 rejects the old `opt -verify`).
- Python in `.venv/` only for side tools (tiktoken BPE comparison).
- Commands: `make` (build `build/fplc`) · `make tools` (versions) · `make hooks` (once per clone). Planned: `./run_tests.sh` (all tests), `make package`.
- CI (GitHub Actions, Ubuntu 24.04 = the grading OS, apt LLVM 18) must stay green; it runs `./run_tests.sh` automatically once that file exists. Keep emitted IR valid for LLVM 18 as well as 23.

## References

- Professor's repo, with newer lectures and example code: https://github.com/adaskin/compiler-course (`lecture-notes/5-bison-example/`, `lecture-notes/8-semantic-analysis-type-checking/`)
- LLVM LangRef: https://llvm.org/docs/LangRef.html · Kaleidoscope: https://llvm.org/docs/tutorial/
- Flex manual: https://westes.github.io/flex/manual/ · Bison manual: https://www.gnu.org/software/bison/manual/
- Thain, *Introduction to Compilers and Language Design* (free online) · Crafting Interpreters
