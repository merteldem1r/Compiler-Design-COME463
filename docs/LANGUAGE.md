# Anka Language Specification

> **Anka** (`.anka`) is a small, statically typed, C-like language, designed to be compiled end to end over one semester.
> Named after the phoenix of Turkish mythology: like the bird, its compiler rises from errors (it reports them and keeps going).

**Status:** v0.1, lexical structure fixed for Project 1. Sections marked *planned* are previews for later projects and may change.
**Compiler binary:** `ankac` · **Source files:** `*.anka`

---

## 1. A taste of Anka

```anka
/* Recursive factorial.
   /* Comments nest, so you can comment out code that has comments. */
*/
fn fact(n: int) -> int {
    if (n <= 1) { return 1; }
    return n * fact(n - 1);
}

fn main() -> int {
    for i in 0..6 {
        if (i % 2 == 1) { continue; }
        print(fact(i));            // 1, 2, 24
    }
    return 0;
}
```

---

## 2. Lexical structure (Project 1)

### 2.1 Character set and whitespace
- Source files are ASCII. Any other byte is a lexical error.
- Whitespace (`' '`, `\t`, `\r`, `\n`) separates tokens and is otherwise ignored. Indentation has **no meaning**.
- Each `\n` increments the line counter. Lines start at 1.

### 2.2 Comments
| Kind | Syntax | Rule |
|---|---|---|
| Single-line | `// ...` | Runs to the end of the line |
| Multi-line | `/* ... */` | **Nests**: `/* a /* b */ c */` is one comment. May span lines |

A `/*` with no matching `*/` before end of file is an error, reported at the line where the comment **opened**.

### 2.3 Keywords (15, all reserved)

| Group | Keywords | Tokens |
|---|---|---|
| Declarations | `fn` `let` | `FN` `LET` |
| Control flow | `if` `else` `while` `for` `in` `return` `break` `continue` | `IF` `ELSE` `WHILE` `FOR` `IN` `RETURN` `BREAK` `CONTINUE` |
| Built-in statement | `print` | `PRINT` |
| Types | `int` `float` `bool` | `TYPE_INT` `TYPE_FLOAT` `TYPE_BOOL` |
| Boolean literals | `true` `false` | `TRUE` `FALSE` |

Keywords are case-sensitive: `If` and `WHILE` are ordinary identifiers.

### 2.4 Token table

| Category | Token | Regex (Flex) | Examples |
|---|---|---|---|
| Identifier | `IDENT` | `[a-zA-Z_][a-zA-Z0-9_]*` | `x`, `total_sum`, `_tmp`, `ifx` |
| Integer literal | `INT_LIT` | `0\|[1-9][0-9]*` | `0`, `42`, `1000` |
| Float literal | `FLOAT_LIT` | `[0-9]+\.[0-9]+([eE][+-]?[0-9]+)?\|[0-9]+[eE][+-]?[0-9]+` | `3.14`, `0.5`, `2.5e-3`, `1e10` |
| String literal | `STRING_LIT` | `\"([^"\\\n]\|\\.)*\"` | `"hi"`, `"a\tb\n"`, `"say \"hi\""` |
| Arithmetic | `PLUS` `MINUS` `STAR` `SLASH` `PERCENT` `POW` | `+` `-` `*` `/` `%` `**` | `a ** 2` |
| Assignment | `ASSIGN` `PLUS_ASSIGN` `MINUS_ASSIGN` `STAR_ASSIGN` `SLASH_ASSIGN` | `=` `+=` `-=` `*=` `/=` | `x += 1` |
| Comparison | `EQ` `NEQ` `LT` `LE` `GT` `GE` | `==` `!=` `<` `<=` `>` `>=` | `i <= n` |
| Logical | `AND` `OR` `NOT` | `&&` `\|\|` `!` | `!done && ok` |
| Arrow | `ARROW` | `->` | `fn f() -> int` |
| Range | `DOTDOT` | `\.\.` | `0..10` |
| Punctuation | `LPAREN` `RPAREN` `LBRACE` `RBRACE` `SEMI` `COMMA` `COLON` | `(` `)` `{` `}` `;` `,` `:` | `f(a, b);` |
| End of input | `END` | `<<EOF>>` | |

That is 22 operators (10 of them multi-character) and 7 punctuation marks.

Notes:
- **No negative literals.** `-5` is `MINUS INT_LIT(5)`. The sign belongs to the parser (unary minus), not the lexer.
- String escapes allowed: `\n` `\t` `\"` `\\`. Strings cannot span lines. Strings may only appear as the argument of `print` (checked in P3).
- Floats need digits on **both** sides of `.`: `1.` and `.5` are not floats (see §2.6).

### 2.5 How ambiguity is resolved
1. **Maximal munch**: the longest possible match wins. `==` is one `EQ`, not two `ASSIGN`s. `**` is `POW`; `+=` is `PLUS_ASSIGN`; `->` is `ARROW`; `ifx` is `IDENT("ifx")`, not `IF` + `IDENT("x")`.
2. **Rule priority**: when two rules match the *same* length, the rule listed first wins. Keyword rules come **before** the identifier rule, so `if` is `IF`, not `IDENT("if")`.

Walk-through of `ifx`: the keyword rule `if` matches 2 characters and the identifier rule matches 3. Maximal munch picks the longer match, giving `IDENT("ifx")`. Priority only decides ties, and there is no tie here.

### 2.6 Lexical errors
The lexer **reports, skips, and continues**. It never stops at the first error.

| Error | Example | Behaviour |
|---|---|---|
| Unknown character | `let x@y = 5;` | Report `'@'`, skip 1 char → `LET IDENT(x) IDENT(y) ASSIGN INT_LIT(5) SEMI` |
| Integer with leading zeros | `007` | Report the whole lexeme as one error (rule `0[0-9]+`) |
| Unterminated string | `"hello` + newline | Report at that line, resume on the next line |
| Invalid escape | `"a\qb"` | Report `\q`; the string token is still produced |
| Unterminated comment | `/* ...` EOF | Report at the line where the comment opened |
| Lone `.` | `1.` / `.5` | `.` alone is not a token, so report `'.'` (`1.` → `INT_LIT(1)` + error) |

### 2.7 Lexer traps (things our tests prove)

| Input | Tokens | Why |
|---|---|---|
| `0..5` | `INT_LIT(0) DOTDOT INT_LIT(5)` | A float needs a digit after `.`, so `0.` cannot start a float |
| `1.5..2` | `FLOAT_LIT(1.5) DOTDOT INT_LIT(2)` | Maximal munch stops the float at `1.5` |
| `a-->b` | `IDENT MINUS ARROW IDENT` | Munch takes `-`, then `->` |
| `x**-2` | `IDENT POW MINUS INT_LIT` | `**` beats `*` `*` |
| `/* a /* b */ c */` | *(nothing)* | Nesting depth goes 1 → 2 → 1 → 0 |

### 2.8 Output format (`ankac --tokens`)
One token per line, errors inline, all on standard output:
```
LINE 1: FN          'fn'
LINE 1: IDENT       'fact'
LINE 3: ERROR       unexpected character '@'
LINE 9: END
```

---

## 3. Example programs

**Example 1: functions, recursion, `->`, `**`**
```anka
fn power_sum(n: int) -> int {
    if (n == 0) { return 0; }
    return n ** 2 + power_sum(n - 1);
}

fn main() -> int {
    let total: int = power_sum(4);   // 1 + 4 + 9 + 16
    print("total = ");
    print(total);
    return 0;
}
```

**Example 2: loops, `break` / `continue`, compound assignment, `%`**
```anka
fn main() -> int {
    let evens: int = 0;
    for i in 0..20 {
        if (i % 2 != 0) { continue; }
        if (i > 10) { break; }
        evens += 1;
    }
    let n: int = 27;
    while (n != 1 && n > 0) { if (n % 2 == 0) { n /= 2; } else { n = 3 * n + 1; } }
    return evens;
}
```

**Example 3: floats, booleans, strings, nested comments**
```anka
/* Area helper
   /* TODO: support more shapes */
*/
fn circle_area(r: float) -> float {
    return 3.14159 * r ** 2;
}

fn main() -> int {
    let big: bool = circle_area(2.5e0) >= 10.0;
    if (!big) { print("small\n"); } else { print("big\n"); }
    return 0;
}
```

---

## 4. Syntax overview (*planned*, Project 2)

Informal shape of the grammar. The precise Bison grammar comes in P2.

```
program     → function*
function    → 'fn' IDENT '(' params? ')' ('->' type)? block
params      → IDENT ':' type (',' IDENT ':' type)*
type        → 'int' | 'float' | 'bool'
block       → '{' statement* '}'
statement   → 'let' IDENT ':' type '=' expr ';'
            | IDENT ('=' | '+=' | '-=' | '*=' | '/=') expr ';'
            | 'if' '(' expr ')' block ('else' (block | if-statement))?
            | 'while' '(' expr ')' block
            | 'for' IDENT 'in' expr '..' expr block
            | 'return' expr? ';' | 'break' ';' | 'continue' ';'
            | 'print' '(' (expr | STRING_LIT) ')' ';'
            | expr ';'
```

Operator precedence, lowest to highest:

| Level | Operators | Associativity |
|---|---|---|
| 1 | `\|\|` | left |
| 2 | `&&` | left |
| 3 | `==` `!=` | none |
| 4 | `<` `<=` `>` `>=` | none |
| 5 | `+` `-` | left |
| 6 | `*` `/` `%` | left |
| 7 | unary `-` `!` | right |
| 8 | `**` | **right** (`2**3**2` = `2**9`) |

`..` is not a general operator; it only appears in a `for` header.

## 5. Types and semantics (*planned*, Project 3)
- Types: `int`, `float`, `bool`. A function with no `->` returns nothing.
- Static typing, with no implicit conversion between `int` and `float` (to be confirmed in P3).
- `%` is int-only. Conditions must be `bool`. `break` and `continue` are only legal inside loops.
- `for i in a..b`: `a` and `b` are `int`; `i` is a fresh `int` scoped to the loop body; the end `b` is exclusive.
- Block scoping: an inner `let` may shadow an outer variable.

---

## 6. Design decisions

1. **Floats require digits on both sides of the dot.** This makes `0..5` unambiguous with plain maximal munch: `0.` can never start a float, so the lexer reads `INT DOTDOT INT` without lookahead tricks. Cost: `1.` and `.5` are not valid, which matches C-family readability and catches typos.
2. **Comments nest.** Programmers often comment out code that already contains comments; in C that silently breaks. Nesting needs a *counter*, which no regular expression or finite automaton can provide (lecture 4: "a finite automaton cannot count"). We implement it with a Flex start condition plus a depth variable, a small step outside regular languages, inside the lexer.
3. **`print` is a keyword, and strings are print-only.** The lexer still handles full string literals (escapes, unterminated errors), but the language has no `string` type. This keeps P3 type checking and P4 code generation free of string memory management.
4. **Leading zeros are an error, not three tokens.** Without the `0[0-9]+` error rule, maximal munch would turn `007` into `INT(0) INT(0) INT(7)`, a confusing result. One clear error is better.
5. **Types are written after the name (`x: int`).** The parser knows a declaration starts at `let` and a parameter at `IDENT ':'`, which avoids C's "is this a type or an expression?" ambiguity.
