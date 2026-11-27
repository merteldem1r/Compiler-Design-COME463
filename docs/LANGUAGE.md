# Anka Language Specification

> **Anka** is a small, strictly evaluated, statically typed **functional** language. Every construct is an expression, functions are values, and nothing is ever mutated. It compiles to LLVM IR with `fplc`.
> Named after the phoenix of Turkish mythology: its compiler rises from errors (it reports them all and keeps going), and Anka v1.0 rose from the C-like Anka v0.2 of Project 1.

**Status:** **v1.0 draft**, written 2026-11-27, **waiting for the student's review** (see §12). The source of truth for the final project. `SPEC.md` (root) is its ≤ 2-page summary.
**Compiler:** `fplc` · **Source files:** `*.fpl` · **Directive:** `projects/final-project/directives/final_project.md`
**Previous version:** `projects/project-1/LANGUAGE-v0.2.md` (Project 1 lexer, C-like; frozen)

---

## 1. A taste of Anka

```anka
// Top-level functions start with `fn`. Every parameter and every return type is written out.
fn double(x: int) -> int = x * 2

fn apply(f: int -> int, x: int) -> int = f(x)       // functions are values

fn fact(n: int) -> int =
  if n <= 1 then 1 else n * fact(n - 1)             // `if` is an expression

fn main() -> int =                                  // the program runs main()
  let x = 5 in                                      // immutable local binding
  let y = apply(double, x) in
  print_int(if y > fact(3) then y else fact(3))     // prints 10
```

The shape a reader needs: **a program is a list of `fn` definitions**, one of which is `main`. A function body is **one expression**. `let … in` names a value, `if … then … else` picks one, `fun (x: int) -> …` makes an anonymous function, and calls are written `f(a, b)`, like in C, Python or Rust.

---

## 2. Lexical structure

### 2.1 Characters, whitespace, positions
- Source files are ASCII. Inside comments any byte is allowed (`// açıklama` is fine). Anywhere else, a non-ASCII byte is a lexical error.
- Whitespace (`' '`, `\t`, `\r`, `\n`) separates tokens and is otherwise ignored. Indentation and line breaks **have no meaning**.
- Positions are **line:column**, both starting at 1. The column counts bytes; a tab counts as one column. A token's position is that of its first character.

### 2.2 Comments
| Kind | Syntax | Rule |
|---|---|---|
| Line | `// …` | Runs to the end of the line |
| Block | `/* … */` | **Nests**: `/* a /* b */ c */` is one comment. May span lines |

A `/*` without a matching `*/` is an error, reported at the position of the **opening** `/*`.

### 2.3 Keywords (11, reserved, case-sensitive)

| Group | Keywords | Tokens |
|---|---|---|
| Functions | `fn` `fun` | `FN` `FUN` |
| Binding | `let` `in` | `LET` `IN` |
| Conditional | `if` `then` `else` | `IF` `THEN` `ELSE` |
| Types | `int` `bool` | `TYPE_INT` `TYPE_BOOL` |
| Boolean literals | `true` `false` | `TRUE` `FALSE` |

`print_int` and `print_bool` are **not** keywords. They are ordinary names that are predefined in the global scope (§5.4), so they can be passed as values: `apply(print_int, 7)`.

### 2.4 Token table

| Category | Token | Regex (Flex) | Examples |
|---|---|---|---|
| Identifier | `IDENT` | `[a-zA-Z_][a-zA-Z0-9_]*` | `x`, `is_prime`, `_`, `fx2` |
| Integer literal | `INT_LIT` | `0\|[1-9][0-9]*` | `0`, `42`, `2147483647` |
| Arithmetic | `PLUS` `MINUS` `STAR` `SLASH` `PERCENT` | `+` `-` `*` `/` `%` | `a % b` |
| Comparison | `EQ` `NEQ` `LT` `LE` `GT` `GE` | `==` `!=` `<` `<=` `>` `>=` | `n <= 1` |
| Logical | `AND` `OR` `NOT` | `&&` `\|\|` `!` | `!done && ok` |
| Arrow | `ARROW` | `->` | `int -> int`, `fun (x: int) -> x` |
| Binding `=` | `EQUALS` | `=` | `let x = 1 in x` |
| Punctuation | `LPAREN` `RPAREN` `COMMA` `COLON` | `(` `)` `,` `:` | `f(a, b)` |
| End of input | `END` (code 0, as Bison expects) | `<<EOF>>` | |

That is 16 operators (7 of them two characters long: `==` `!=` `<=` `>=` `&&` `||` `->`) and 4 punctuation marks. `=` is called `EQUALS`, not `ASSIGN`, because Anka has no assignment: `=` only introduces a name.

Notes:
- **No negative literals.** `-5` is `MINUS INT_LIT(5)`; the parser treats `-` as unary minus.
- **Range:** an integer literal must be ≤ `2147483647` (the largest `int`). `2147483648` is a lexical error even after a `-`. Write the smallest int as `-2147483647 - 1`.
- **Leading zeros** (`007`) are an error, as in Project 1.

### 2.5 How ambiguity is resolved
1. **Maximal munch:** the longest match wins. `==` is one `EQ`, not two `EQUALS`; `->` is `ARROW`, not `MINUS GT`; `iffy` is `IDENT`, not `IF` + `IDENT(fy)`.
2. **Rule priority:** on a tie in length, the rule listed first wins. Keyword rules come **before** the identifier rule, so `then` is `THEN`.

### 2.6 Lexical errors
The lexer **reports, skips, and continues**. Every error uses the diagnostic format of §8.

| Error | Example | Message (draft wording) |
|---|---|---|
| Unknown character | `x @ y`, `;`, `{` | `unexpected character '@'` |
| Non-ASCII byte | `ı` (2 bytes) | `unexpected byte '\xC4'` (one per byte) |
| Leading zeros | `007` | `integer literal '007' has leading zeros` |
| Too large | `3000000000` | `integer literal '3000000000' is too large (max 2147483647)` |
| Unterminated comment | `/* …` EOF | `unterminated comment` (at the opening `/*`) |

### 2.7 What changed since v0.2 (Project 1)
| Removed (forbidden by the final project: no mutation, no loops, int/bool only) | Added |
|---|---|
| `while` `for` `break` `continue` `return` `print` `float`, float and string literals, `=` as assignment, `+=` `-=` `*=` `/=`, `**`, `..`, `{` `}` `;` | `fun` `then`, built-in names `print_int`/`print_bool`, columns in every position, `int` range check |

---

## 3. Syntax

### 3.1 Grammar (EBNF)

```ebnf
program   = fndef { fndef } ;                                   (* one of them is main *)
fndef     = "fn" IDENT "(" [ params ] ")" "->" type "=" expr ;
params    = param { "," param } ;
param     = IDENT ":" type ;

type      = atype [ "->" type ]                                 (* right-associative *)
          | "(" ")" "->" type                                   (* no parameters *)
          | "(" type "," type { "," type } ")" "->" type ;      (* several parameters *)
atype     = "int" | "bool" | "(" type ")" ;

expr      = "let" IDENT [ ":" type ] "=" expr "in" expr
          | "if" expr "then" expr "else" expr
          | "fun" "(" [ params ] ")" "->" expr
          | or_expr ;
or_expr   = and_expr { "||" and_expr } ;
and_expr  = cmp_expr { "&&" cmp_expr } ;
cmp_expr  = add_expr [ ( "==" | "!=" | "<" | "<=" | ">" | ">=" ) add_expr ] ;
add_expr  = mul_expr { ( "+" | "-" ) mul_expr } ;
mul_expr  = unary { ( "*" | "/" | "%" ) unary } ;
unary     = ( "-" | "!" ) unary | call ;
call      = atom { "(" [ args ] ")" } ;                         (* f(x), f(x)(y) *)
args      = expr { "," expr } ;
atom      = INT_LIT | "true" | "false" | IDENT | "(" expr ")" ;
```

This grammar is LALR(1) with **zero conflicts**. We checked it with Bison 3.8.2 before writing this spec (§11, decision 3).

### 3.2 Precedence and associativity (lowest to highest)

| Level | Construct | Associativity | Example → meaning |
|---|---|---|---|
| 1 | `let … in e`, `if … else e`, `fun (…) -> e` | extend **as far right as possible** | `if c then 1 else 2 + 3` → else-branch is `2 + 3` |
| 2 | `\|\|` | left | `a \|\| b \|\| c` → `(a \|\| b) \|\| c` |
| 3 | `&&` | left | `a \|\| b && c` → `a \|\| (b && c)` |
| 4 | `==` `!=` `<` `<=` `>` `>=` | **none** (one comparison per level) | `a < b < c` is a syntax error; write `a < b && b < c` |
| 5 | `+` `-` | left | `10 - 3 - 2` → `(10 - 3) - 2` = 5 |
| 6 | `*` `/` `%` | left | `1 + 2 * 3` → `1 + (2 * 3)` |
| 7 | unary `-` `!` | right (prefix) | `-x * y` → `(-x) * y` |
| 8 | call `f(…)` | left (postfix) | `-f(2)` → `-(f(2))`; `pick(b)(7)` → `(pick(b))(7)` |

Level-1 forms are **not** operands: `1 + if c then 2 else 3` is a syntax error. Write `1 + (if c then 2 else 3)`. They are allowed directly wherever a full `expr` is expected: a function body, a call argument, a `then`/`else` branch, a `let` value or body, and inside parentheses.

### 3.3 Style (for humans; the compiler ignores layout)
One `let … in` per line, the body of a multi-line function indented by two spaces, `->` and `=` surrounded by spaces. To do two things in order, bind the first result to `_`: `let _ = print_int(a) in print_int(b)`.

---

## 4. Types

```
T ::= int | bool | (T1, …, Tn) -> T
```
- `int`: 32-bit signed integer. `bool`: `true` / `false`.
- Function types are written `S -> T` for one parameter, `(S1, S2) -> T` for several, and `() -> T` for none. `->` is right-associative: `int -> int -> int` = `int -> (int -> int)`, a function that takes an int and **returns a function**. `(int) -> int` is the same type as `int -> int`.
- Two types are equal when they have the same shape (structural equality).
- No inference of parameters or return types: every `fn` parameter, every `fn` return type, and every `fun` parameter is annotated. A `let` annotation is optional. A `fun` body's type is computed, not written (see the rule below).
- **Internal only:** the type checker also uses an `error` type. It is never written by the programmer (§8.3).

---

## 5. Static semantics (type checking)

`Γ ⊢ e : T` means "in scope Γ, expression `e` has type `T`".

### 5.1 Type rules

| Construct | Rule |
|---|---|
| `n` (integer literal) | `: int` |
| `true`, `false` | `: bool` |
| `x` | `: Γ(x)`; error if `x` is not in scope |
| `-e` | `e : int` ⇒ `-e : int` |
| `!e` | `e : bool` ⇒ `!e : bool` |
| `e1 + e2` (also `-` `*` `/` `%`) | `e1 : int`, `e2 : int` ⇒ `int` |
| `e1 < e2` (also `<=` `>` `>=`) | `e1 : int`, `e2 : int` ⇒ `bool` |
| `e1 == e2` (also `!=`) | `e1 : T`, `e2 : T`, `T` is `int` or `bool` ⇒ `bool` (functions cannot be compared) |
| `e1 && e2` (also `\|\|`) | `e1 : bool`, `e2 : bool` ⇒ `bool` |
| `if e1 then e2 else e3` | `e1 : bool`, `e2 : T`, `e3 : T` ⇒ `T` |
| `let x = e1 in e2` | `e1 : S`, and `e2 : T` with `x : S` added to Γ ⇒ `T` |
| `let x: A = e1 in e2` | as above, and `S` must equal `A` |
| `fun (x1: S1, …, xn: Sn) -> e` | `e : T` in Γ₀ + {x1 : S1 … xn : Sn} ⇒ `(S1, …, Sn) -> T`. **Γ₀ = global scope only** (no capture, §5.3) |
| `f(a1, …, an)` | `f : (S1, …, Sn) -> T`, **exactly n** arguments, `ai : Si` ⇒ `T`. `f` may be any expression of function type |
| `fn f(x1: S1, …) -> T = e` | `e : T` in Γ₀ + {x1 : S1, …} |

### 5.2 Scopes and shadowing
- **Global scope Γ₀:** the built-ins and **every** top-level `fn`, all visible everywhere, in any order. The checker first collects all signatures, then checks the bodies. That is what makes recursion and **mutual recursion** (`is_even` ↔ `is_odd`) work.
- A function's parameters form a scope inside Γ₀. Each `let` opens a new scope for its body only.
- **Shadowing is allowed:** a parameter or `let` may reuse any outer name, including a top-level function or a built-in. `let x = x * 10 in …` reads the old `x` on the right and binds a new `x` for the body.
- Not allowed: two top-level functions with the same name; redefining a built-in at top level (`fn print_int(…)`); two parameters with the same name in one list.

### 5.3 Anonymous functions cannot capture
Inside `fun (…) -> e`, the body `e` may use **only** its own parameters, its own inner `let`s, the top-level functions and the built-ins. Using a `let` variable or a parameter from an enclosing function is an error (the directive's baseline; closures are an optional bonus):
```anka
fn add_to_all(k: int) -> int =
  apply(fun (x: int) -> x + k, 1)     // error: 'k' is captured; pass it as a parameter instead
```

### 5.4 Built-ins
| Name | Type | Effect |
|---|---|---|
| `print_int` | `int -> int` | prints the number in decimal and a newline; returns `0` |
| `print_bool` | `bool -> int` | prints `true` or `false` and a newline; returns `0` |

### 5.5 The program
- A program must define `fn main() -> int` (no parameters, returns `int`). The program runs by calling `main()`. **Its result is ignored**, and the process exits with status 0. There are no top-level expressions; this is decision 3 in §11.
- Missing `main`, or a `main` with the wrong type, is a type error.

---

## 6. Dynamic semantics (what a program does)

- **Strict, left-to-right, call-by-value:** arguments are evaluated left to right, then the function is called. In `e1 op e2`, `e1` is evaluated first.
- **Short-circuit:** `e1 && e2` doesn't evaluate `e2` when `e1` is `false`; `e1 || e2` doesn't when `e1` is `true`.
- `if` evaluates the condition, then **only** the chosen branch.
- `let` evaluates its value once; the name then stands for that value (immutable).
- **Integers wrap** (two's complement, 32 bits): `2147483647 + 1` = `-2147483648`. Unary `-` wraps too.
- `/` truncates toward zero (`-7 / 2` = `-3`); `%` takes the sign of the left operand (`-7 % 2` = `-1`). `-2147483648 / -1` = `-2147483648` (wraps) and `-2147483648 % -1` = `0`. In LLVM this case is undefined behaviour, so the compiler handles it explicitly.
- **Division or remainder by zero** stops the program. It prints `<file>:<line>:<col>: runtime error: division by zero` to stderr (the position of the `/` or `%`) and exits with status **1**.
- **No partial application:** a call always supplies every argument (checked statically).
- Functions (top-level, built-in, or `fun`) are values: they can be passed, returned, bound by `let`, and chosen by `if`.
- Deep recursion uses the machine stack (no tail-call elimination in the baseline).

---

## 7. Compiler interface

```bash
./fplc prog.fpl --emit-ast              # parse; print the AST (§9) to stdout
./fplc prog.fpl --check                 # parse + type check; no output on success
./fplc prog.fpl --emit-ll -o prog.ll    # parse + type check + write LLVM IR (stdout if no -o)
./fplc prog.fpl --tokens                # debugging: the token stream
clang prog.ll runtime.c -o prog && ./prog
```
- Exit status `0` on success, **`1` on any error** (usage, file, lexical, syntax, type).
- On any error nothing is generated: no AST printout, and no `.ll` file is created.
- If there are syntax errors, type checking is skipped, because there is no reliable AST to check.

---

## 8. Diagnostics

### 8.1 Format
Every compile-time diagnostic goes to **stderr**, one line each, in source order within a phase:
```
<file>:<line>:<col>: error: <message>
```

### 8.2 Messages (draft wording, fixed by the tests in Phases 1–2)
Messages name **what was expected and what was found**, and say how to fix it where the fix is not obvious. This helps humans, and it is what an LLM gets back in the repair loop (§10).

| Kind | Example message |
|---|---|
| Syntax | `unexpected 'else', expected 'then'` · `unexpected end of file, expected an expression` |
| Unbound | `unbound variable 'y'` |
| Operator | `right operand of '+': expected int, found bool` |
| Equality | `'==' needs two values of the same type: found int and bool` · `cannot compare functions with '=='` |
| Condition | `condition of 'if': expected bool, found int` |
| Branches | `branches of 'if' have different types: 'then' is int, 'else' is bool` |
| Call | `'x' is not a function, it has type int` · `'f' expects 2 arguments, found 1 (Anka has no partial application)` · `argument 1 of 'f': expected int -> int, found int` |
| Return | `body of 'f': expected int (the declared return type), found bool` |
| Let | `'x' is declared int, but its value has type bool` |
| Capture | `anonymous function cannot capture 'k' (bound at 1:15); pass it as a parameter instead` |
| Program | `duplicate function 'f' (first defined at 2:4)` · `duplicate parameter 'x'` · `cannot redefine built-in 'print_int'` · `missing 'fn main() -> int'` · `'main' must have type () -> int, found int -> int` |

Example (three independent errors, one run):
```anka
fn f(x: int) -> int = x + true
fn main() -> int =
  let y = 1 in
  let g = fun (z: int) -> z + y in
  f(1, 2)
```
```
prog.fpl:1:27: error: right operand of '+': expected int, found bool
prog.fpl:4:31: error: anonymous function cannot capture 'y' (bound at 3:7); pass it as a parameter instead
prog.fpl:5:3: error: 'f' expects 1 argument, found 2 (Anka has no partial application)
```

### 8.3 Recovery
- **Syntax (Phase 1): panic mode.** On a syntax error the parser reports it, skips tokens until a synchronizing token (`in`, `then`, `else`, `let`, `)`, `fn`, or end of file), and continues. It reports several independent errors in one run.
- **Types (Phase 2): the `error` type.** An expression that failed to check gets type `error`. `error` is accepted wherever any type is expected, without a new message, so one mistake gives **one** diagnostic, not a cascade.
- Recovery only improves the report; a program with any error is **never** accepted.

---

## 9. AST dump (`--emit-ast`)

One node per line; children indented two more spaces than their parent. Types are printed in source syntax.

| Node | Line printed | Children |
|---|---|---|
| program | `Program` | its functions |
| `fn` | `Fn fact(n: int) -> int` | body |
| integer | `Int 42` | — |
| boolean | `Bool true` | — |
| variable | `Var x` | — |
| unary | `Unary -` / `Unary !` | operand |
| binary | `Binary +` (any binary operator) | left, right |
| `if` | `If` | condition, then, else |
| `let` | `Let x` / `Let x: int` | value, body |
| `fun` | `Fun (x: int)` | body |
| call | `Call` | callee, then each argument |

```anka
fn main() -> int = print_int(1 + 2 * 3)
```
```
Program
  Fn main() -> int
    Call
      Var print_int
      Binary +
        Int 1
        Binary *
          Int 2
          Int 3
```

---

## 10. Example programs (outputs computed by hand)

**Example 1: recursion, function values, `if` as an expression.** Output: `10`
```anka
fn double(x: int) -> int = x * 2
fn apply(f: int -> int, x: int) -> int = f(x)
fn fact(n: int) -> int =
  if n <= 1 then 1 else n * fact(n - 1)

fn main() -> int =
  let x = 5 in
  let y = apply(double, x) in               // 10
  print_int(if y > fact(3) then y else fact(3))
```

**Example 2: mutual recursion, `print_bool`, sequencing with `let _`.** Output: `true` `true`
```anka
fn is_even(n: int) -> bool = if n == 0 then true else is_odd(n - 1)
fn is_odd(n: int) -> bool = if n == 0 then false else is_even(n - 1)

fn main() -> int =
  let _ = print_bool(is_even(10)) in
  print_bool(is_odd(7))
```

**Example 3: anonymous functions, returning a function.** Output: `81` `70`
```anka
fn twice(f: int -> int, x: int) -> int = f(f(x))
fn pick(b: bool) -> int -> int =
  if b then fun (x: int) -> x + 1 else fun (x: int) -> x * 10

fn main() -> int =
  let _ = print_int(twice(fun (n: int) -> n * n, 3)) in   // (3*3)*(3*3) = 81
  print_int(pick(false)(7))                               // 7 * 10 = 70
```

**Example 4: shadowing, precedence, a `let` annotation.** Output: `5` `-18`
```anka
fn main() -> int =
  let x = 2 in
  let y: int = x + 3 * 4 in        // 2 + 12 = 14
  let x = x * 10 in                // a new x = 20; the old x is shadowed
  let _ = print_int(x - y - 1) in  // (20 - 14) - 1 = 5
  print_int(-x + y % 4)            // -20 + 2 = -18
```

**Example 5: gcd with `%`, short-circuit guarding a division.** Output: `6` `false` `true`
```anka
fn gcd(a: int, b: int) -> int = if b == 0 then a else gcd(b, a % b)
fn big_ratio(a: int, b: int) -> bool = b != 0 && a / b > 10

fn main() -> int =
  let _ = print_int(gcd(48, 18)) in            // gcd(18,12) -> gcd(12,6) -> gcd(6,0) = 6
  let _ = print_bool(big_ratio(100, 0)) in     // false: a / b is never evaluated
  print_bool(big_ratio(100, 5))                // 20 > 10: true
```

**Example 6: a runtime error.** Output on stderr: `prog.fpl:2:16: runtime error: division by zero`, exit status 1
```anka
fn main() -> int =
  print_int(10 / (5 - 5))
```

---

## 11. Design decisions (with the alternatives we rejected)

1. **C-style calls `f(x, y)`, not ML-style `f x y`.** *Rejected:* juxtaposition, as in the directive's example. It looks clean, but `fact n - 1` silently means `(fact n) - 1`, and `print_int f x` is ambiguous to a reader. LLMs see `f(x)` in almost all of their training code (Python, JS, C, Rust). Parentheses also make "no partial application" visible: the argument count is right there.
2. **Every parameter and return type is annotated; no inference.** *Rejected:* Hindley–Milner inference (a bonus option). With annotations, each signature documents itself for a human, gives an LLM the contract up front, and keeps the checker simple: a body is checked against the signature, so an error is reported **inside the function where it happens**, not at a distant use. `let` stays unannotated by default, because its type is obvious from the right-hand side.
3. **A program is only `fn` definitions, and it runs `main()`.** *Rejected:* the directive's "definitions, then one trailing expression". We tried it in Bison and it gives **3 shift/reduce conflicts**: after `fn f() -> int = g`, a following expression `(5)` or `-5` could just as well continue `f`'s body (`g(5)`, `g - 5`). Bison would silently shift and glue them together. With `fn main`, every top-level item starts with `fn`, the grammar has zero conflicts, and the entry point is the one humans and LLMs expect.
4. **One keyword per idea.** `fn` defines a named function, `fun` builds an anonymous one, `let … in` binds a local. *Rejected:* `let` for both top-level functions and locals, as in the directive's example. That is a second source of conflicts, and it makes readers guess which kind of `let` they're looking at.
5. **Built-ins are ordinary names, not keywords.** *Rejected:* Project 1's `print` keyword. As names, `print_int` and `print_bool` get their types from the same rules as user functions, and they can be passed as values.
6. **No statement separator `;`.** Sequencing is `let _ = e1 in e2`. *Kept out on purpose, for now:* it is the most likely thing an LLM will get wrong, which makes it a candidate for the "change one thing" step of the LLM experiment (with a better `unexpected character ';'` message as the other candidate).

**For humans and LLMs:** a small and regular grammar (11 keywords, one way to write each idea); explicit types at every function boundary; familiar call syntax; diagnostics that state the position, what was expected, what was found, and a fix.

---

## 12. Review checklist (student, before Phase 1 code)

The AI drafted these choices. Confirm or change each one; then v1.0 is final and `SPEC.md` is written from it.

- [ ] `fn main() -> int` is required, and its result is ignored (exit 0). *Alternative:* use the result as the exit code.
- [ ] `print_int` / `print_bool` return `0`. *Alternative:* return the argument (only works for `print_int`).
- [ ] Lambdas may take any number of parameters (`fun (a: int, b: int) -> a + b`), the same as `fn`. The directive only requires one.
- [ ] Optional `let` annotation `let x: int = …`.
- [ ] One non-associative comparison level (`a < b < c` is an error), as in the directive's grammar. v0.2 had two levels.
- [ ] Keep `%`, `!`, nested comments (not required, but cheap and useful for gcd / is_prime).
- [ ] Integer literals above 2147483647 are a lexical error.
- [ ] Runtime error format `file:line:col: runtime error: division by zero`, exit status 1.
- [ ] `--check` and `--tokens` as extra modes besides the required `--emit-ast` / `--emit-ll`.
- [ ] AST dump format of §9 (indented tree, not S-expressions).
