# Makefile for ankac, the Anka compiler.
#   make             build build/ankac
#   make test        run the golden-file tests (TEST_DIR/X.anka must print EXPECTED_DIR/X.out)
#   make bpe         regenerate the BPE comparison (needs .venv with tiktoken)
#   make pdf-p1      SPEC.html / REPORT.html -> PDF with headless Chrome (macOS, authoring only)
#   make package-p1  build dist/project1.zip for submission
#   make clean       delete build/
# Generated files and binaries live in build/ and are never committed.

CC     ?= cc
CFLAGS  = -std=c11 -Wall -Wextra -pedantic -D_POSIX_C_SOURCE=200809L
FLEX    = flex
BUILD   = build

# Folder layout. "?=" means: use this value unless it was already set. The submission
# zip puts tests in tests/ and expected outputs in output/, so its copy of this Makefile
# starts with three lines that set these differently (see package-p1).
TEST_DIR     ?= tests/lexer
EXPECTED_DIR ?= $(TEST_DIR)/expected
BPE_DIR      ?= projects/project-1/solution/bpe

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

# Golden-file tests: TEST_DIR/X.anka must print exactly EXPECTED_DIR/X.out.
# The exit status of ankac is ignored here; error cases are part of the expected output.
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

# BPE comparison (Project 1, Step 5). One-time setup:
#   python3 -m venv .venv && .venv/bin/pip install -r $(BPE_DIR)/requirements.txt
bpe: $(BUILD)/ankac
	.venv/bin/python $(BPE_DIR)/bpe_compare.py $(TEST_DIR) > $(BPE_DIR)/results.md
	@echo "wrote $(BPE_DIR)/results.md"

# ---- Project 1 submission (repository only; not part of the zip's workflow) ----
P1_SRC = projects/project-1/solution
P1_OUT = dist/project1
CHROME = /Applications/Google Chrome.app/Contents/MacOS/Google Chrome

# The SPEC and REPORT are written as HTML and printed to PDF by headless Chrome.
pdf-p1:
	"$(CHROME)" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=$(P1_SRC)/SPEC.pdf file://$(CURDIR)/$(P1_SRC)/SPEC.html
	"$(CHROME)" --headless --disable-gpu --no-pdf-header-footer --print-to-pdf=$(P1_SRC)/REPORT.pdf file://$(CURDIR)/$(P1_SRC)/REPORT.html

# Copy everything into the layout the assignment asks for, then zip it.
# Runs the tests first, so a broken lexer can never be packaged.
package-p1: test
	rm -rf $(P1_OUT) dist/project1.zip
	mkdir -p $(P1_OUT)/src $(P1_OUT)/tests $(P1_OUT)/output $(P1_OUT)/bpe
	cp $(P1_SRC)/README.md $(P1_SRC)/SPEC.pdf $(P1_SRC)/REPORT.pdf $(P1_OUT)/
	cp src/tokens.h src/lexer.l src/main.c $(P1_OUT)/src/
	cp $(TEST_DIR)/*.anka $(P1_OUT)/tests/
	cp $(EXPECTED_DIR)/*.out $(P1_OUT)/output/
	cp $(BPE_DIR)/bpe_compare.py $(BPE_DIR)/requirements.txt $(BPE_DIR)/results.md $(P1_OUT)/bpe/
	{ echo "TEST_DIR = tests"; echo "EXPECTED_DIR = output"; echo "BPE_DIR = bpe"; echo; cat Makefile; } > $(P1_OUT)/Makefile
	cd dist && zip -qr project1.zip project1 -x '*.DS_Store'
	@echo "wrote dist/project1.zip"

clean:
	rm -rf $(BUILD)

.PHONY: all test bpe pdf-p1 package-p1 clean
