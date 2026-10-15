# Makefile for ankac, the Anka compiler.
#   make         build build/ankac
#   make test    run the golden-file tests in tests/lexer/
#   make clean   delete build/
# Generated files and binaries live in build/ and are never committed.

CC     ?= cc
CFLAGS  = -std=c11 -Wall -Wextra -pedantic -D_POSIX_C_SOURCE=200809L
FLEX    = flex
BUILD   = build

all: $(BUILD)/ankac

$(BUILD):
	mkdir -p $(BUILD)

# Step 1: Flex turns the rules in lexer.l into a C scanner (a DFA as tables).
$(BUILD)/lex.yy.c: src/lexer.l src/tokens.h | $(BUILD)
	$(FLEX) -o $@ src/lexer.l

# Step 2: compile the generated scanner. Flex's own code compares a signed and an
# unsigned int (-Wsign-compare); we silence only that, only for this generated file.
$(BUILD)/lex.yy.o: $(BUILD)/lex.yy.c src/tokens.h
	$(CC) $(CFLAGS) -Wno-sign-compare -Isrc -c -o $@ $(BUILD)/lex.yy.c

# Step 3: compile our driver with every warning on, then link both into ankac.
$(BUILD)/main.o: src/main.c src/tokens.h | $(BUILD)
	$(CC) $(CFLAGS) -Isrc -c -o $@ src/main.c

$(BUILD)/ankac: $(BUILD)/lex.yy.o $(BUILD)/main.o
	$(CC) -o $@ $(BUILD)/lex.yy.o $(BUILD)/main.o

# Golden-file tests: tests/lexer/X.anka must print exactly tests/lexer/expected/X.out.
# The exit status of ankac is ignored here; error cases are part of the expected output.
test: $(BUILD)/ankac
	@pass=0; fail=0; \
	for f in tests/lexer/*.anka; do \
	    name=$$(basename $$f .anka); \
	    if $(BUILD)/ankac --tokens $$f | diff -u tests/lexer/expected/$$name.out - > $(BUILD)/$$name.diff; then \
	        echo "PASS  $$name"; pass=$$((pass + 1)); \
	    else \
	        echo "FAIL  $$name   (see $(BUILD)/$$name.diff)"; fail=$$((fail + 1)); \
	    fi; \
	done; \
	echo "$$pass passed, $$fail failed"; \
	test $$fail -eq 0

clean:
	rm -rf $(BUILD)

.PHONY: all test clean
