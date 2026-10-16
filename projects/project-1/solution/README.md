# BIL 463 Project 1: Anka Lexer

**Group members:** Mert Eldemir (25120205086), working alone
**Path:** A (C + Flex)
**Language:** Anka (`*.anka`), specified in `SPEC.pdf`
**AI tools used:** Claude Code (Anthropic, model Claude Opus 5.5). Prompts, what it got wrong, and how that was fixed are in `REPORT.pdf`, Section 3.

## Contents

```
project1/
├── README.md        this file
├── SPEC.pdf         language specification (1 page)
├── REPORT.pdf       design, testing and bugs, AI usage + BPE comparison
├── Makefile         build, test, BPE
├── src/             the lexer: lexer.l (Flex rules), tokens.h (token codes), main.c (driver)
├── tests/           8 test files, 34 numbered cases (each file's header lists its cases)
├── output/          expected output for each test (tests/X.anka -> output/X.out)
└── bpe/             BPE comparison: bpe_compare.py, requirements.txt, results.md
```

## Build and run

Requirements: Flex 2.6, a C11 compiler (gcc or clang), make.

```bash
make                                       # builds build/ankac
./build/ankac --tokens tests/numbers.anka  # one token per line: LINE n: NAME 'lexeme'
echo 'let x@y = 5;' | ./build/ankac --tokens
make test                                  # runs every test, compares with output/; expects "8 passed, 0 failed"
make clean                                 # deletes build/
```

Exit status of `ankac`: 0 = no lexical errors, 1 = lexical errors were reported, 2 = usage or file error.

## BPE comparison (optional to re-run)

```bash
python3 -m venv .venv && .venv/bin/pip install -r bpe/requirements.txt
make bpe                                   # regenerates bpe/results.md
```

## Notes

- `tests/crlf_line_endings.anka` uses Windows line endings (`\r\n`) on purpose: it is the regression test for bug 3 in the report. Do not convert it.
- Generated files (`lex.yy.c`, object files, the binary) go into `build/`.
