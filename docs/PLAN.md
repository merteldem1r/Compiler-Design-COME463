# Current Plan — Final Project: Anka, a functional language compiled to LLVM

> The working plan for the **current** milestone. When it ships, summarize it in `ROADMAP.md` and rewrite this file.

**Directive:** `projects/final-project/directives/final_project.md` (the professor's text, verbatim)
**Demo: Tue 2026-12-15** (class, 10 minutes). **Submission:** "end of week 14". Working deadline **Sun 2026-12-13** until the exact date/format is confirmed.
**Solo** (confirmed by the professor). Graded as **two projects**. **Path A:** C11 + Flex + Bison, emitting `.ll` text.
**Tools:** Flex 2.6.4 · Bison 3.8.2 and LLVM/clang 23.1.6 from Homebrew (keg-only, the Makefile finds them) · `make tools` prints the versions.

## What is graded

| Phase | Weight | Content |
|---|---|---|
| 1 Spec + parser + AST | 30 | SPEC.md (≤ 2 pages, 5+ examples), lexer, parser, real AST, `--emit-ast`, located syntax errors, panic-mode recovery, tests |
| 2 Type checker | 30 | Scopes + shadowing, all type rules, (mutual) recursion, lambda capture errors, expected/found diagnostics, `error` type so errors don't cascade, tests |
| 3 LLVM codegen | 40 | `--emit-ll` valid IR, `br`+`phi`, SSA lets, calls/recursion/function values, div-by-zero check, `runtime.c`, `run_tests.sh`, no crashes |

The report (3 pages) and the demo count inside the phase grades, mostly Phase 3. Bonus +10%: later, if there is time (`--diagnostics=json` is the cheapest).

## Deliverable layout (the repo root mirrors it)

```
README.md   SPEC.md   src/   runtime.c   tests/{valid,errors,recovery}/   examples/   run_tests.sh   REPORT.pdf
```
Interface fixed by the directive: `./fplc prog.fpl --emit-ast`, `./fplc prog.fpl --emit-ll -o prog.ll`, diagnostics `<file>:<line>:<col>: error: <message>` on stderr, exit 0/1, no `.ll` written on error.

## Schedule

| Dates | Work | Phase |
|---|---|---|
| Fri 11-27 | Analysis ✅ · toolchain ✅ · repo reorganized, P1 frozen ✅ | — |
| Sat 11-28 – Sun 11-29 | `docs/LANGUAGE.md` v1.0 (student review) → `SPEC.md` v1 · **walking skeleton**: `print_int(42)` through lexer → parser → AST → checker → `.ll` → clang → `42` | setup |
| Mon 11-30 – Wed 12-02 | Lexer update (new tokens, columns), `parser.y`, AST, `--emit-ast`, panic-mode recovery, syntax-error + recovery tests | 1 |
| Thu 12-03 – Sun 12-06 | Type checker + type-error and recovery tests | 2 |
| Mon 12-07 – Thu 12-10 | Code generator, `runtime.c`, `run_tests.sh`, valid tests, 30+ line program, `examples/` | 3 |
| Thu 12-10 – Sat 12-12 | LLM experiment, BPE comparison | report |
| Sat 12-12 – Sun 12-13 | `REPORT.pdf`, README, package + dry run from an empty folder, **submit** | report |
| Mon 12-14 | One slide, rehearse the demo (incl. the professor's mutation test) | demo |

## Checklist

### Setup
- [x] Toolchain: `brew install bison llvm`; checked a hand-written `.ll` with `opt -passes=verify`, linked with clang, it printed `120` (2026-11-27)
- [x] Repo reorganized: P1 frozen in `projects/project-1/code/` (still 8/8), root = final project (2026-11-27)
- [x] `.githooks/commit-msg` + `make hooks`; `.github/workflows/ci.yml` (commit messages, gcc + clang `-Werror`, P1 tests, `run_tests.sh` when it exists) (2026-11-27)
- [ ] **Student:** make the GitHub repo private (it is PUBLIC; course policy forbids posting solutions), run `make hooks`, push, and check that the first CI run is green
- [x] `docs/LANGUAGE.md` v1.0 **draft**: tokens, grammar (Bison-checked, 0 conflicts), precedence, type rules, semantics, CLI, messages, AST dump, 6 examples with hand-computed output, design decisions (2026-11-27)
- [ ] **Student reviews** `docs/LANGUAGE.md` §12 checklist → v1.0 final
- [ ] `SPEC.md` v1 (≤ 2 pages, 5+ example programs), made from LANGUAGE.md. Keep v1 forever: it is the LLM experiment's baseline
- [ ] Walking skeleton `print_int(42)` end to end

### Phase 1: parser + AST
- [ ] Lexer: remove P1-only tokens (loops, assignment ops, float, string, `**`, `..`, braces/`;`); add `then`, `fun`, `print_int`/`print_bool` as built-in names; track **columns** (`yylloc`); diagnostics in the new format on stderr
- [ ] `tokens.h` replaced by Bison's generated header
- [ ] `src/parser.y` (Bison 3): grammar + precedence; `let…in` / `if…else` / `fun` extend as far right as possible
- [ ] `src/ast.{c,h}`: AST node types, constructors, `free`, `--emit-ast` printer
- [ ] Panic-mode recovery with `error` rules, resynchronizing on `in`, `then`, `else`, `let`, `)`, EOF; reports several independent errors
- [ ] Tests: ≥ 5 syntax errors in `tests/errors/`, recovery cases in `tests/recovery/`

### Phase 2: type checker
- [ ] Symbol table with nested scopes + shadowing
- [ ] Two passes: collect every top-level signature first, then check bodies (mutual recursion)
- [ ] All type rules; call arity and argument types; `if` condition is `bool` and both branches have the same type
- [ ] Lambda capture detection: a `fun` body may use only its parameter, top-level functions and built-ins
- [ ] Diagnostics: location + expected type + found type; internal `error` type that matches anything silently (no cascades)
- [ ] Tests: ≥ 5 type errors, ≥ 3 recovery files in total (multiple errors, no cascades)

### Phase 3: LLVM code generation
- [ ] `--emit-ll -o`: `add/sub/mul/sdiv/srem/icmp`, `if` → `br` + `phi`, `let` → SSA values, calls, recursion
- [ ] `&&` / `||` short-circuit (branches + `phi`, not `and`/`or`)
- [ ] Function values as `ptr`; lambdas lifted to hidden top-level functions (possible because they cannot capture)
- [ ] Division by zero: check before `sdiv`/`srem`, call a runtime function that prints to stderr and exits nonzero. Also `INT_MIN / -1` (UB in LLVM, but our ints wrap)
- [ ] `runtime.c`: `print_int`, `print_bool`, the div-by-zero handler
- [ ] Decide what to do about clang's `-Woverride-module` warning (target triple)
- [ ] `run_tests.sh`: builds, runs valid/errors/recovery, `opt -passes=verify` on every `.ll`, prints PASS/FAIL; truncation test (cut valid files at random points: never a crash)
- [ ] ≥ 10 valid tests (precedence, shadowing, recursion, higher-order, `if` as expression), 1 runtime div-by-zero test, one 30+ line program
- [ ] Expected outputs hand-computed (or from a reference interpreter), **never generated by `fplc` itself**
- [ ] Check that the suite catches a mutation (`add` → `sub` in codegen) before the demo
- [ ] `examples/`: `.ll` for 2–3 demo programs

### Report, LLM experiment, demo
- [ ] LLM experiment: 10 small tasks (2 use function values); a **fresh** LLM chat that sees only `SPEC.md`, one task at a time; record compiles / correct / error category; feed our error message back once; change one thing in spec/grammar/messages; re-measure
- [ ] BPE (tiktoken) counts of our examples vs equivalent Python and OCaml
- [ ] `REPORT.pdf` (3 pages): design (3 decisions + rejected alternatives, humans + LLMs), architecture + recovery + **3 real bugs** + test counts, LLM results + the change + conclusion; AI disclosure (2–3 prompts verbatim, one AI mistake)
- [ ] `README.md`: author, path, LLVM version, build/run instructions
- [ ] `make package` + dry run from an empty folder (clang; gcc check if possible) · submit · `git tag final-submission`
- [ ] Demo: one slide, valid program → output, errors → diagnostics, AST/IR dump, hardest bug, LLM results

## Bugs log (raw material for REPORT §2, needs 3)

| Date | What failed | Why | Fix |
|---|---|---|---|
| 2026-11-27 | **Spec bug:** the directive-style program shape `{ fndef } expr` gave Bison **3 shift/reduce conflicts** (on `(` and `-`) | With C-style calls, after `fn f() -> int = g` the next token `(5)` or `-5` can continue the body (`g(5)`, `g - 5`) *or* start the main expression. Bison's default (shift) would silently glue them | Program = only `fn` definitions + required `fn main() -> int`. Same grammar → 0 conflicts (checked with Bison 3.8.2, `-Wcounterexamples`). LANGUAGE.md §11 decision 3 |

## Open questions
- [ ] Exact submission date and format (Classroom zip?) for "end of week 14"
- [ ] Reference interpreter: an `fplc --interp` mode in C over the same AST, or only hand-computed outputs? (Decide before Phase 3 tests)
- [ ] Which LLM runs the experiment (must be a fresh chat with only `SPEC.md`)
- [ ] Bonus: decide after Phase 3 works

## Decisions log

| Date | Decision | Why |
|---|---|---|
| 2026-10-14 | Path A: C + Flex (+ Bison) | Lectures and examples are Flex/Bison-first; C is a prerequisite |
| 2026-10-14 | The repo is the agent memory (`PLAN.md`, `SESSION_LOG.md`, `AI_USAGE.md`); the agent never runs git write commands | Solo, multi-session work; the student keeps control of history |
| 2026-10-14 | Close every session with `/wrap-up` → student runs the git block → `/exit`; a hook flags missed wrap-ups | A session log was lost once |
| 2026-11-27 | **Evolve the existing repo, don't restart.** Anka keeps its name, but its grammar is redesigned as functional (v1.0) | The directive asks for one codebase; the lexer structure, Makefile, test method and docs workflow carry over. The P1 statement grammar (loops, mutation, floats, strings) is forbidden by the new rules |
| 2026-11-27 | **C-style calls `f(x, y)`**, not ML-style `f x` | Familiar to humans and LLMs (Python/JS/Rust); avoids the `fact n - 1` = `(fact n) - 1` trap; reuses `(`, `)`, `,` from P1 |
| 2026-11-27 | Top-level functions start with `fn`, local bindings are `let … in`; a program is `{ fn-def } expr` | The parser knows from the first token whether it sees a definition or the main expression |
| 2026-11-27 | Source extension `.fpl`, binary `fplc` | Matches the professor's fixed CLI and test harness |
| 2026-11-27 | P1 frozen as a buildable snapshot in `projects/project-1/code/`; the root `src/lexer.l` is the copy that evolves | P1 stays reproducible; `git diff` shows how the lexer changed for the final project |
| 2026-11-27 | Commit-message hook in a tracked `.githooks/` (enabled by `make hooks`), and the same script in CI, which checks only newly pushed commits | `.git/hooks/` is not versioned. One script means the local and CI rules can't drift. Old commits (`last updates`, `testing with own .anka code`) are history and are not rewritten |
| 2026-11-27 | CI on GitHub Actions, Ubuntu 24.04, gcc + clang with `-Werror` | Linux + gcc is the grading environment; apt's LLVM 18 also checks that our IR isn't tied to LLVM 23 |
| 2026-11-27 | Verify IR with `opt -passes=verify -disable-output` | LLVM 23 rejects the directive's `opt -verify` (old pass-manager syntax). Same check, new spelling |
