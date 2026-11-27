---
paths:
  - "src/**"
  - "tests/**"
  - "runtime.c"
  - "run_tests.sh"
  - "examples/**"
  - "Makefile"
---

# C / Flex / Bison / LLVM IR standards

## General
- **C11**, compiled with `-std=c11 -Wall -Wextra -pedantic`. Must build warning-free with both `clang` (macOS) and `gcc` (Linux, the grading environment).
- Keep it simple and close to the lecture examples (professor's repo: `lecture-notes/5-bison-example/`, `8-semantic-analysis-type-checking/`). No premature optimization.
- Small files with one responsibility each: `lexer.l`, `parser.y`, `ast.{c,h}`, `check.{c,h}`, `codegen.{c,h}`, `main.c`; `runtime.c` at the root.
- Free what you allocate. The compiler must **never crash, hang or segfault**, not even on truncated input.
- Generated files (`lex.yy.c`, `*.tab.c/h`, `*.ll` outside `examples/`) and binaries go to `build/` and are never committed.

## Diagnostics (fixed by the directive)
- Format on **stderr**: `<file>:<line>:<col>: error: <message>`. Type errors name the expected and the found type.
- Exit `0` on success, `1` on any error; on error no `.ll` file is written.
- Recovery reports several independent errors but **never accepts an invalid program**.

## Flex lexer
- Use `%option noyywrap nounput noinput yylineno`; track columns for `yylloc`.
- Rule order expresses **priority**: keywords **before** the identifier rule, and a catch-all `.` error rule **last**. Maximal munch handles `==` vs `=` by itself; don't hand-code lookahead.
- Name named definitions (`DIGIT`, `LETTER`) in the definitions section and reuse them. Comment any non-obvious regex with what it accepts and rejects.
- Multi-line comments: use a start condition (`%x COMMENT`) so line counting works and an unterminated comment at EOF is reported.
- Token codes come from Bison's generated header. Every token must appear in `docs/LANGUAGE.md`. Spec first, then code.

## Bison parser
- Bison 3 (`/opt/homebrew/opt/bison/bin/bison` on macOS; the Makefile picks it). Build an **AST** in the actions, not a parse tree.
- Prefer precedence declarations or grammar layers that mirror the spec's precedence table; explain every `%prec` and every remaining conflict (target: zero conflicts).
- Panic-mode recovery with `error` rules that resynchronize on `in`, `then`, `else`, `let`, `)`, EOF.

## LLVM IR
- Emit readable `.ll` text by hand (no LLVM C API). Every emitted file must pass `opt -passes=verify -disable-output` (LLVM 23 rejects the old `opt -verify`).
- ints are `i32` and wrap; bools are `i1`; function values are `ptr`.

## Tests
- Layout fixed by the directive: `tests/valid/X.fpl` + `X.expected` (program stdout), `tests/errors/X.fpl` + `X.expected` (diagnostics), `tests/recovery/X.fpl` + `X.expected` (several diagnostics from one run). `./run_tests.sh` builds everything, runs all tests, prints PASS/FAIL.
- Expected outputs are **hand-computed** (or from a reference interpreter), never produced by `fplc` itself.
- Each test file starts with a comment listing the cases it covers. Cover valid programs, edge cases, and error cases.
- A bug fix comes with a test that would have caught it, and a "Bugs hit" note for `docs/SESSION_LOG.md`.
- Never change an expected file just to make a failing test pass without stating why the old expectation was wrong.
