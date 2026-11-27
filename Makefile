# Makefile for fplc, the Anka compiler (final project, projects/final-project/directives/).
#   make          build build/fplc
#   make tools    print the tool versions (README.md must state the LLVM version)
#   make hooks    use the repo's git hooks in .githooks/ (once per clone)
#   make clean    delete build/
# Grows phase by phase: parser.y + ast.c (Phase 1), check.c (Phase 2), codegen.c +
# runtime.c + run_tests.sh (Phase 3). Until the walking skeleton replaces main.c,
# fplc is still the Project 1 token dumper (fplc --tokens file).
# Generated files and binaries live in build/ and are never committed.

CC     ?= cc
# EXTRA_CFLAGS is empty here; CI sets it to -Werror so any warning fails the build.
CFLAGS  = -std=c11 -Wall -Wextra -pedantic -D_POSIX_C_SOURCE=200809L $(EXTRA_CFLAGS)
BUILD   = build

# Homebrew installs Bison 3 and LLVM "keg-only": they are NOT on the PATH, because macOS
# ships its own old bison (2.3) and Apple clang. $(wildcard X) is X if that file exists,
# else empty, so $(firstword ...) picks the Homebrew copy on a Mac and the plain name on
# Linux, where `apt install bison llvm clang` puts them on the PATH.
BREW   = /opt/homebrew/opt
FLEX   = flex
BISON  = $(firstword $(wildcard $(BREW)/bison/bin/bison) bison)
CLANG  = $(firstword $(wildcard $(BREW)/llvm/bin/clang) clang)
OPT    = $(firstword $(wildcard $(BREW)/llvm/bin/opt) opt)

all: $(BUILD)/fplc

$(BUILD):
	mkdir -p $(BUILD)

# Flex turns lexer.l into a C scanner. Its generated code compares a signed and an
# unsigned int (-Wsign-compare, P1 bug #1); we silence only that, only for this file.
$(BUILD)/lex.yy.c: src/lexer.l src/tokens.h | $(BUILD)
	$(FLEX) -o $@ src/lexer.l

$(BUILD)/lex.yy.o: $(BUILD)/lex.yy.c src/tokens.h
	$(CC) $(CFLAGS) -Wno-sign-compare -Isrc -c -o $@ $(BUILD)/lex.yy.c

$(BUILD)/main.o: src/main.c src/tokens.h | $(BUILD)
	$(CC) $(CFLAGS) -Isrc -c -o $@ src/main.c

$(BUILD)/fplc: $(BUILD)/lex.yy.o $(BUILD)/main.o
	$(CC) -o $@ $(BUILD)/lex.yy.o $(BUILD)/main.o

tools:
	@$(FLEX) --version
	@$(BISON) --version | head -1
	@$(CLANG) --version | head -1
	@$(OPT) --version | grep -i 'llvm version'

# Git only runs hooks from .git/hooks/, which is not versioned. This points it at the
# tracked .githooks/ folder instead (a local config change, not a commit).
hooks:
	git config core.hooksPath .githooks
	@echo "git hooks enabled: .githooks/commit-msg checks every commit message"

clean:
	rm -rf $(BUILD)

.PHONY: all tools hooks clean
