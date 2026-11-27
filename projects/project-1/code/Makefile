# Project 1 (Anka lexer), frozen snapshot. Submitted 2026-10; do not develop here.
# The final-project compiler grows from a copy of this lexer in the repo-root src/.
# Run from this folder:
#   make         build build/ankac
#   make test    golden-file tests: tests/X.anka must print tests/expected/X.out
#   make bpe     regenerate ../solution/bpe/results.md (needs the repo-root .venv with tiktoken)
#   make clean   delete build/

CC     ?= cc
CFLAGS  = -std=c11 -Wall -Wextra -pedantic -D_POSIX_C_SOURCE=200809L
FLEX    = flex
BUILD   = build

TEST_DIR     = tests
EXPECTED_DIR = $(TEST_DIR)/expected
BPE_DIR      = ../solution/bpe
VENV_PY      = ../../../.venv/bin/python

all: $(BUILD)/ankac

$(BUILD):
	mkdir -p $(BUILD)

# Flex turns lexer.l into a C scanner; its generated code trips -Wsign-compare (bug #1).
$(BUILD)/lex.yy.c: src/lexer.l src/tokens.h | $(BUILD)
	$(FLEX) -o $@ src/lexer.l

$(BUILD)/lex.yy.o: $(BUILD)/lex.yy.c src/tokens.h
	$(CC) $(CFLAGS) -Wno-sign-compare -Isrc -c -o $@ $(BUILD)/lex.yy.c

$(BUILD)/main.o: src/main.c src/tokens.h | $(BUILD)
	$(CC) $(CFLAGS) -Isrc -c -o $@ src/main.c

$(BUILD)/ankac: $(BUILD)/lex.yy.o $(BUILD)/main.o
	$(CC) -o $@ $(BUILD)/lex.yy.o $(BUILD)/main.o

test: $(BUILD)/ankac
	@pass=0; fail=0; \
	for f in $(TEST_DIR)/*.anka; do \
	    name=$$(basename $$f .anka); \
	    if $(BUILD)/ankac --tokens $$f | diff -u $(EXPECTED_DIR)/$$name.out - > $(BUILD)/$$name.diff; then \
	        echo "PASS  $$name"; pass=$$((pass + 1)); \
	    else \
	        echo "FAIL  $$name   (see $(BUILD)/$$name.diff)"; fail=$$((fail + 1)); \
	    fi; \
	done; \
	echo "$$pass passed, $$fail failed"; \
	test $$fail -eq 0

bpe: $(BUILD)/ankac
	$(VENV_PY) $(BPE_DIR)/bpe_compare.py $(TEST_DIR) > $(BPE_DIR)/results.md
	@echo "wrote $(BPE_DIR)/results.md"

clean:
	rm -rf $(BUILD)

.PHONY: all test bpe clean
