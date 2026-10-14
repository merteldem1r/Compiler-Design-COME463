# Course Roadmap — BIL/COME 463 Compiler Design (Fall 2026)

## The goal in one sentence

By the end of the semester we hand in **one working compiler for a small language ("MiniLang")** that we build up in 4 milestones. Each milestone adds one compiler phase on top of the previous one, so the code is one growing program and not four separate projects.

```
source.mini ──► [Lexer] ──► tokens ──► [Parser] ──► AST ──► [Semantic] ──► typed AST ──► [IR + Codegen] ──► runnable output
                 M1                     M2                    M3                          M4
```

Required features across the whole language (lecture 1): variables, functions, arithmetic. It must report **lexical, syntax, and type errors** and produce **executable output**, with **tests and documentation**.

## Grading (where the effort pays off)

| Component | Weight | What it means for us |
|---|---|---|
| Final exam | 40% | Theory (automata, grammars, parse tables, types) **+ questions about our own project** |
| Programming projects | 30% | The 4 milestones below. No late submissions. |
| Midterm | 20% | Same style as the written assignments |
| Written assignments | 10% | 2–3 sets: automata, grammars, parsing tables, type systems |

AI tools are allowed, but every report has to acknowledge them and **we must be able to explain every line**. That is why `docs/AI_USAGE.md` records what the agent did.

## Milestones

| # | Milestone | Lecture weeks | Lecture notes to study | Status |
|---|---|---|---|---|
| M1 | **Lexer** (due **Mon 2026-10-20**): own-language spec, Flex scanner, tests, BPE comparison + handwritten RE→NFA→DFA theory | 2–3 | `2-lexical-analysis.pdf`, `3-lexical-analysis-II.pdf` | 🔜 in progress, see [PLAN.md](PLAN.md) |
| M2 | **Parser + AST**: CFG for MiniLang, precedence, AST building, syntax error recovery | 4–6 | `4-parser.pdf`, `5-top-down-parser.pdf`, LR notes (week 6, not posted yet) | ⏳ |
| M3 | **Semantic analysis**: symbol table, scopes, type checking | 7–8 | not posted yet | ⏳ |
| M4 | **IR + code generation**: three-address code / stack bytecode / C or asm output | 9–10 | not posted yet | ⏳ |
| ★ | **AI extension (bonus, optional)**: e.g. tensor DSL → fused NumPy/C | any | lecture 1, "AI-flavored extensions" | ⏳ decide by M2 |

Weeks 11–15 (global optimization, register allocation, AI compilers, agents, presentations) carry no new milestone but are exam material, and week 15 includes **project presentations**.

## Theory track (for the exams, alongside the project)

- [ ] Regex → NFA (Thompson) → DFA (subset construction) → minimal DFA (Hopcroft): do these by hand
- [ ] Maximal munch and rule priority; why `if` is a keyword and not an identifier
- [ ] CFGs, leftmost/rightmost derivations, parse trees, ambiguity (dangling else, `E+E*E`)
- [ ] Precedence and associativity (`%left`, `%right`, `%prec`)
- [ ] Left recursion elimination, left factoring, FIRST/FOLLOW, LL(1) table
- [ ] Synthesized vs inherited attributes, semantic actions
- [ ] LR / SLR / LALR tables (week 6)
- [ ] The "AI connection" slides: BPE as a learned lexer, constrained decoding as parsing, and so on (these are likely exam questions)

## Working rules

1. **The language spec comes first.** `docs/LANGUAGE.md` is the single source of truth for MiniLang. Code follows the spec.
2. **One compiler, growing.** Compiler code lives in `src/`. `projects/project-N/directives/` holds the professor's text and `projects/project-N/solution/` our report and submission files.
3. **Tests from day one.** Each input in `tests/` has an expected-output file in `expected/`, and `make test` diffs them.
4. **Tag every submission** (`git tag p1-submission`) so we can always show what was handed in.
