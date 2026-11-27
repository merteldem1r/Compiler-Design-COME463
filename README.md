# Anka: a small functional language compiled to LLVM

[![CI](https://github.com/merteldem1r/Compiler-Design-COME463/actions/workflows/ci.yml/badge.svg)](https://github.com/merteldem1r/Compiler-Design-COME463/actions/workflows/ci.yml)

**Course:** BIL/COME 463 Compiler Design, Fall 2026 · Instructor: Prof. Ammar Daşkın
**Author:** Mert Eldemir (student no. 25120205086), working alone
**Implementation path:** A, meaning C11 + Flex + Bison, emitting LLVM IR as text

This repository holds one compiler that grew over the semester. **Project 1** built a lexer. The **final project** turns it into `fplc`, a complete compiler for **Anka**, a small statically typed functional language. It is designed to be easy to read for both **humans and LLMs**, and part of the project measures how well an LLM can write it.

> The name: the *Anka* is the phoenix of Turkish mythology. Its compiler rises from errors: it reports every error it can find in one run instead of stopping at the first.

---

## A taste of Anka

```anka
fn double(x: int) -> int = x * 2
fn apply(f: int -> int, x: int) -> int = f(x)        // functions are values

fn fact(n: int) -> int =
  if n <= 1 then 1 else n * fact(n - 1)              // `if` is an expression

fn main() -> int =                                   // the program runs main()
  let y = apply(double, 5) in                        // immutable local binding
  print_int(if y > fact(3) then y else fact(3))      // prints 10
```

- Types `int` (32-bit, wraps on overflow) and `bool`, plus function types such as `int -> int`.
- Everything is an **expression**: `let … in`, `if … then … else`, anonymous functions `fun (x: int) -> x + 1`.
- Every function parameter and return type is written out (no type inference). Calls look like C: `f(a, b)`.
- No mutation, no loops (recursion instead), and output only through the built-ins `print_int` and `print_bool`.

The full language definition is in [`docs/LANGUAGE.md`](docs/LANGUAGE.md).

## How the compiler works

```
prog.fpl ─► Lexer ─► tokens ─► Parser ─► AST ─► Type checker ─► Code generator ─► prog.ll ─► clang + runtime.c ─► ./prog
            (Flex)             (Bison)          (symbol table)                     (LLVM IR)
            ◄──────────── Phase 1 ───────────►  ◄─ Phase 2 ─►  ◄──────────────────── Phase 3 ─────────────────────►
```

1. **Lexer** (`src/lexer.l`): cuts the source text into tokens (`fn`, `x`, `->`, `42`, …) and reports bad characters with their line and column.
2. **Parser** (`src/parser.y`): checks the grammar and builds an **AST** (abstract syntax tree), a tree of the program's structure. On a syntax error it skips ahead to a safe token and keeps going, so it reports several errors in one run.
3. **Type checker**: checks that every expression has a valid type (for example, an `if` condition must be `bool`), that every name is defined, and that anonymous functions don't use outer variables.
4. **Code generator**: translates the checked AST into **LLVM IR**, a readable, assembly-like text. `clang` then compiles it, together with a tiny C runtime for the print functions, into a native program.

Errors are printed in the standard form `prog.fpl:3:14: error: condition of 'if': expected bool, found int`. The exit status is `1` and nothing is generated.

## Status

| Part | State |
|---|---|
| Project 1: lexer for Anka v0.2 (C-like) | ✅ submitted, frozen in [`projects/project-1/`](projects/project-1/) |
| Final project: language spec, Anka v1.0 | 📝 draft in `docs/LANGUAGE.md`, under review |
| Phase 1: lexer update, parser, AST, `--emit-ast`, syntax error recovery | ⏳ next |
| Phase 2: type checker | ⏳ |
| Phase 3: LLVM code generation, runtime, full test suite | ⏳ |
| Report, LLM experiment, demo (Tue 2026-12-15) | ⏳ |

The current plan and checklist are in [`docs/PLAN.md`](docs/PLAN.md).

---

## Requirements

| Tool | Version used | Needed for |
|---|---|---|
| C compiler (clang or gcc) | Apple clang 21, gcc 15 | building `fplc` (C11) |
| Flex | 2.6.4 | the lexer |
| GNU Bison | **3.x** (3.8.2) | the parser (macOS's built-in Bison 2.3 is too old) |
| LLVM + clang | 23.1.6 (CI also uses 18) | `opt` to verify the IR, `clang` to build the program |
| make | any | building |
| Python 3 + tiktoken | optional | the BPE token-count comparison |

**macOS (Homebrew):**
```bash
brew install bison llvm
```
Both packages are *keg-only*: Homebrew doesn't put them on the PATH, because macOS already has its own `bison` and `clang`. You don't need to change the PATH: the Makefile finds them in `/opt/homebrew/opt/`.

**Ubuntu / Debian:**
```bash
sudo apt-get install flex bison llvm clang make gcc
```

Check what the Makefile will use:
```bash
make tools
```

## Build and run

```bash
make                  # builds build/fplc
make clean            # deletes build/
```

**Right now** `fplc` is still the Project 1 token dumper. It prints the token stream of a file:
```bash
./build/fplc --tokens prog.fpl
```

**When the final project is complete**, the interface is the one the assignment fixes:
```bash
./build/fplc prog.fpl --emit-ast              # print the AST
./build/fplc prog.fpl --check                 # parse + type check only
./build/fplc prog.fpl --emit-ll -o prog.ll    # generate LLVM IR
clang prog.ll runtime.c -o prog && ./prog     # build and run the program
./run_tests.sh                                # build everything and run every test
```

## Tests

- **Project 1 (frozen):** 8 test files with 34 numbered cases, each compared with a hand-checked expected output.
  ```bash
  make -C projects/project-1/code test       # expects "8 passed, 0 failed"
  ```
- **Final project (coming with the phases):** `tests/valid/` (programs and their expected output), `tests/errors/` (programs and their expected error messages), and `tests/recovery/` (files with several errors that must all be reported). Expected outputs are worked out by hand, never copied from the compiler itself. `./run_tests.sh` runs everything and also checks every generated `.ll` file with `opt -passes=verify`.

## Repository structure

```
README.md                    this file
Makefile                     make · make tools · make hooks · make clean
src/                         the compiler (lexer.l now; parser.y, ast, type checker, code generator to come)
tests/                       (coming) valid/ · errors/ · recovery/
docs/
  LANGUAGE.md                the Anka v1.0 language specification (source of truth)
  PLAN.md                    current plan, checklist, decisions, bugs found
  ROADMAP.md                 semester overview
  SESSION_LOG.md             what was done in each work session
  AI_USAGE.md                how AI tools were used (required by the course)
  lectures-notes/            course material from the instructor
projects/
  project-1/                 Project 1, submitted and frozen:
    directives/              the assignment text
    solution/                SPEC, REPORT and the BPE comparison as submitted
    code/                    the lexer and its tests, still buildable on their own
    study/                   study notes
  final-project/
    directives/              the final-project assignment text
.githooks/commit-msg         checks commit messages locally
.github/workflows/ci.yml     continuous integration on GitHub Actions
.claude/                     rules and helpers for the AI coding assistant
CLAUDE.md                    orientation file for the AI coding assistant
```

Later phases add the deliverable files at the root: `SPEC.md` (2-page language summary), `runtime.c`, `run_tests.sh`, `examples/` (sample `.ll` output) and `REPORT.pdf`.

## Development workflow

- **Spec first:** `docs/LANGUAGE.md` is changed before the code that implements it.
- **Commit messages** follow `type: summary` (`feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `ci`), at most 72 characters, imperative mood. Enable the local check once per clone:
  ```bash
  make hooks
  ```
- **CI:** every push and pull request runs on GitHub Actions (Ubuntu 24.04). It checks the new commit messages, builds `fplc` with both gcc and clang with warnings treated as errors, and runs the tests.
- **AI use:** the course allows AI tools if their use is disclosed. This project uses Claude Code (Anthropic). Every notable prompt and every mistake the AI made is logged in [`docs/AI_USAGE.md`](docs/AI_USAGE.md), and the author can explain every line.

## Credits

Lecture notes and the assignment texts are by **Prof. Ammar Daşkın**, from the course repository [adaskin/compiler-course](https://github.com/adaskin/compiler-course/).

This is coursework for a running course. Please don't copy or redistribute it as a solution.
