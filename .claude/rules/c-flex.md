---
paths:
  - "src/**"
  - "tests/**"
  - "Makefile"
---

# C / Flex / Bison standards

## General
- **C11**, compiled with `-std=c11 -Wall -Wextra -pedantic`. Must build warning-free with both `clang` (macOS) and `gcc` (Linux, the grading environment).
- Keep it simple and close to the lecture examples (professor's repo: `lecture-notes/3-lexer-minilang-example/flex/`, `5-bison-example/`). No premature optimization.
- Small files with one responsibility each: `lexer.l`, `tokens.h`, `main.c`; later `parser.y`, `ast.{c,h}`, `symbol.{c,h}`, `codegen.{c,h}`.
- Free what you allocate. Report errors with line numbers and keep going where the phase allows.
- Generated files (`lex.yy.c`, `*.tab.c/h`) and binaries go to `build/` and are never committed.

## Flex lexer
- Use `%option noyywrap yylineno` (add `nounput noinput` to silence warnings).
- Rule order expresses **priority**: keywords **before** the identifier rule, and a catch-all `.` error rule **last**. Maximal munch handles `==` vs `=` by itself; don't hand-code lookahead.
- Name named definitions (`DIGIT`, `LETTER`, `ID`) in the definitions section and reuse them. Comment any non-obvious regex with what it accepts and rejects.
- Multi-line comments: use a start condition (`%x COMMENT`) so line counting works and an unterminated comment at EOF is reported.
- Errors: print `LINE n: ERROR: unexpected 'c'` (or the format in `docs/LANGUAGE.md`), skip the character, continue.
- Token codes live in one header (`tokens.h`, later replaced by Bison's generated header) and start at 258 like Bison's.
- Every token must appear in `docs/LANGUAGE.md`. Spec first, then code.

## Tests
- Golden-file tests: `tests/<phase>/<name>.<ext>` input → `tests/<phase>/expected/<name>.out`. `make test` diffs actual against expected and fails on any difference.
- Each test file starts with a comment listing the cases it covers. Cover valid programs, edge cases, and error cases.
- A bug fix comes with a test that would have caught it, and a "Bugs hit" note for `docs/SESSION_LOG.md`.
- Never change an expected file just to make a failing test pass without stating why the old expectation was wrong.
