# CLAUDE.md

Solo student repo for **BIL/COME 463 Compiler Design (Fall 2026, Prof. Ammar Daşkın)**. Over the semester we build **one compiler** for a language we design ourselves, one milestone at a time (lexer → parser/AST → semantic analysis → IR/codegen).

## Every session

1. **Start:** read `docs/PLAN.md` (current milestone, deadline, checklist) and the **latest entry** in `docs/SESSION_LOG.md`. Don't redo work that is already checked off.
2. **End:** run `/wrap-up` (or follow `.claude/skills/wrap-up/SKILL.md`) so the next session, local or cloud, picks up exactly where we stopped. The repo is the memory, and anything not written to these files is lost.

## Course rules that bind the agent

- **AI use is allowed, but the student must be able to explain every line live in class.** Keep code simple, explain each change in plain words, and prefer the lecture's idioms over clever ones.
- **Log AI usage** in `docs/AI_USAGE.md`: notable prompts verbatim, and anything the AI got wrong and how it was fixed. Every project report requires this.
- **Handwritten theory parts** (e.g. P1 Part A) are individual work. Act as a tutor: explain the method, give similar practice examples, and check the student's attempts. Don't hand over final answers to copy.
- Never edit `projects/*/directives/` (the professor's text, kept verbatim) or `docs/lectures-notes/`.
- Keep the repo private. Course policy forbids posting solutions.

## Stack

- **C (C11) + Flex 2.6** for the lexer. Bison 3.x from Homebrew for M2 (`brew install bison`; macOS ships 2.3, which is too old).
- Build with `make`. The code must also build with `gcc` on Linux, the grading environment.
- Python (`.venv/`) only for side tools such as the tiktoken BPE comparison.
- Professor's reference code and newer lectures: https://github.com/adaskin/compiler-course (`lecture-notes/3-lexer-minilang-example/flex/`, `5-bison-example/`, …).

## Layout

```
docs/LANGUAGE.md          living language spec, the source of truth for tokens and grammar
docs/PLAN.md              current milestone: deadline, checklist, decisions
docs/ROADMAP.md           semester overview
docs/SESSION_LOG.md       one entry per session (newest on top)
docs/AI_USAGE.md          AI usage log, feeds the reports
src/                      the compiler; grows each milestone (lexer.l, tokens.h, main.c, …)
tests/lexer/              test inputs; expected outputs in tests/lexer/expected/
projects/project-N/directives/   professor's assignment text (read-only)
projects/project-N/solution/     README, SPEC, REPORT sources and BPE scripts for that submission
```

## Conventions

- Spec first: change `docs/LANGUAGE.md` before changing token rules in `src/`.
- Every lexer behaviour gets a test with an expected-output file. `make test` must pass before work is called done.
- Commit in small steps with clear messages. Tag each submission (`git tag p1-submission`).
