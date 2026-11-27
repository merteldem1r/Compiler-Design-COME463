# Course Roadmap — BIL/COME 463 Compiler Design (Fall 2026)

## The goal in one sentence

By the end of the semester we hand in **one working compiler, `fplc`, for our own small functional language "Anka"**. It parses, type checks, and generates LLVM IR that runs. The language is designed to be easy to read for both humans and LLMs, and we measure how well an LLM handles it.

```
prog.fpl ──► [Lexer] ──► tokens ──► [Parser] ──► AST ──► [Type checker] ──► typed AST ──► [Codegen] ──► prog.ll ──► clang + runtime.c ──► ./prog
              Flex                   Bison        --emit-ast   symbol table                  --emit-ll
             ◄────────── Phase 1 ──────────────►            ◄─ Phase 2 ─►                  ◄──────────── Phase 3 ────────────►
```

## Grading (where the effort pays off)

| Component | Weight | What it means for us |
|---|---|---|
| Final exam | 40% | Theory (automata, grammars, parse tables, types) **+ questions about our own project** |
| Programming projects | 30% | P1 (lexer) + the final project, which **counts as two projects**. No late submissions |
| Midterm | 20% | Same style as the written assignments |
| Written assignments | 10% | Automata, grammars, parsing tables, type systems |

AI tools are allowed, but every report has to acknowledge them and **we must be able to explain every line**. `docs/AI_USAGE.md` records what the agent did.

## Milestones

| # | Milestone | Status |
|---|---|---|
| M1 | **Project 1, lexer**: Anka v0.2 (C-like) spec, Flex scanner, 8 test files / 34 cases, BPE comparison, handwritten RE→NFA→DFA. Frozen in `projects/project-1/` (code, spec, report, study notes) | Done, submitted (2026-10) |
| M2 | **Final project, Phase 1**: Anka v1.0 (functional) spec, Bison parser, AST, `--emit-ast`, syntax errors + panic-mode recovery | In progress, see [PLAN.md](PLAN.md) |
| M3 | **Final project, Phase 2**: type checker, scopes, capture detection, multi-error recovery | Planned |
| M4 | **Final project, Phase 3**: LLVM IR codegen, runtime, `run_tests.sh`, LLM experiment, 3-page report | Planned |
| Demo | Tue **2026-12-15** (10 min: slide, live demo, hardest bug, LLM results) | Planned |

The professor's original 4-milestone plan (separate P2–P4) was replaced by the final project's three phases, all in one codebase.

## Theory track (for the exams, alongside the project)

- [ ] Regex → NFA (Thompson) → DFA (subset construction) → minimal DFA (Hopcroft): by hand
- [ ] Maximal munch and rule priority; why `if` is a keyword and not an identifier
- [ ] CFGs, derivations, parse trees, ambiguity (dangling else, `E+E*E`)
- [ ] Precedence and associativity (`%left`, `%right`, `%nonassoc`, `%prec`)
- [ ] Left recursion elimination, left factoring, FIRST/FOLLOW, LL(1) table
- [ ] LR / SLR / LALR tables, shift/reduce conflicts (we will meet real ones in `parser.y`)
- [ ] Synthesized vs inherited attributes, semantic actions, symbol tables, type rules
- [ ] SSA, `phi`, basic blocks (Phase 3)
- [ ] The "AI connection" slides: BPE as a learned lexer, constrained decoding as parsing

## Working rules

1. **The language spec comes first.** `docs/LANGUAGE.md` is the source of truth; `SPEC.md` is its 2-page summary for the grader and the LLM.
2. **One compiler, growing.** Code lives in root `src/`; tests in root `tests/`. `projects/<name>/directives/` holds the professor's text.
3. **Tests from day one**, with hand-checked expected outputs.
4. **Tag every submission** (`p1-submission`, `final-submission`).
