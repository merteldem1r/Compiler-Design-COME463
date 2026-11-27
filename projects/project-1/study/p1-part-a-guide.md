# Project 1, Part A: study guide (RE → NFA → DFA)

> A guide to the **method**, written so you can do Part A alone. Every worked example here is a *similar* problem, never one of the graded questions (course policy: Part A is individual and handwritten). Practice answers are hidden in collapsible blocks, so try first and check after.
>
> Lecture material: `docs/lectures-notes/2-lexical-analysis.pdf` (regex, DFA basics) and `3-lexical-analysis-II.pdf` (NFA, Thompson, subset construction, Hopcroft). The questions: `projects/project-1/directives/p1.md`, Part A.

---

## 0. Part A in one minute

Part A is a written exam you do at home. It tests the theory behind the lexer we are building in Part B:

```
regular expression  ──Thompson──►  NFA  ──subset construction──►  DFA  ──Hopcroft──►  minimal DFA
   (what to match)                (easy to build)                 (fast to run)         (smallest)
```

Flex does this whole pipeline for us automatically. In Part A you do it **by hand**, on small examples, to show you understand what Flex does.

| Q | You must… | Points | Suggested day |
|---|---|---|---|
| A1 | Write regexes for 5 languages and describe 3 regexes in English, each with 3 accepted and 3 rejected strings | 15 | Thu 15 |
| A2 | Draw a finite automaton for 3 languages | 15 | Fri 16 |
| A3 | Build NFAs with Thompson's construction, showing the steps | 10 | Fri 16 |
| A4 | Convert an NFA to a DFA (table + diagram); check 2 regex pairs for equivalence using minimized DFAs | 15 | Sat 17 |
| A5 | Two short answers (maximal munch; BPE merge order) | 5 | Sun 18 |

**Rules:** handwritten, individual, one scanned PDF, **name and student ID on every page**. Part A is 30% of P1 (the grading table counts 60 points, scaled to 30%).

**Time budget:** about 1.5 hours a day, Thursday to Sunday. A4 takes the longest, so don't leave it for the last day.

---

## 1. Vocabulary (you need all of it)

| Term | Meaning | Example |
|---|---|---|
| Alphabet Σ | The finite set of allowed symbols | Σ = {a, b} |
| String | A finite sequence of symbols, possibly empty | `abba`, ε |
| ε (epsilon) | The **empty string**, length 0 | |
| Language L | A set of strings | L = {strings with even length} |
| L(R) | The language a regex R describes | L(`a*`) = {ε, a, aa, …} |
| `R\|S` | Union: a string from R **or** from S | `a\|b` → {a, b} |
| `RS` | Concatenation: a string from R, **then** a string from S | `ab` → {ab} |
| `R*` | Kleene star: **zero** or more repetitions | `a*` → {ε, a, aa, …} |
| `R+` | One or more, the same as `RR*` | `a+` → {a, aa, …} |
| `R?` | Optional, the same as `R\|ε` | `a?` → {ε, a} |
| `[0-9]` | Any one symbol from the range | |
| DFA | Exactly **one** arrow per (state, symbol), no ε-arrows | |
| NFA | **0, 1 or many** arrows per (state, symbol), ε-arrows allowed. It accepts if **some** path ends in an accepting state | |
| ε-move | An arrow you may take **without reading** a symbol | |
| Dead (trap) state | A non-accepting state that loops to itself on every symbol. Once you enter it, you can never accept | |

**Operator precedence:** `*` `+` `?` bind tightest, then concatenation, then `|`. So `ab*|c` means `(a(b*))|c`.

**Drawing conventions (use them on paper):** an arrow from nowhere marks the start state, a **double circle** marks an accepting state, and every arrow is labeled with its symbol(s) (`a,b` means two arrows). In a transition table, mark the start state with `→` and accepting states with `*`.

---

## 2. A1: regular expressions

### Method (use it for every language)
1. **List some members and non-members** before writing anything. Always ask: **is ε in the language?** What is the shortest member?
2. **Find the structure.** Is it "anything, then X, then anything"? Repeated blocks? Several separate cases?
3. **Split into cases** when one pattern doesn't fit everything, and join the cases with `|`.
4. **Test your regex** against your members and non-members. Each rejected string should break a **different** part of the rule, because that shows the grader you understand the boundaries.
5. **Write down the edge cases you decided**, e.g. "I treat `-0` as valid". A clearly stated assumption earns marks; a silent one looks like a mistake.

### Worked example 1: even-length strings over {a, b}
- Members: ε, `ab`, `bbaa`. Non-members: `a`, `aba`, `bbb`.
- Structure: the string is made of **pairs** of symbols, so repeat "any symbol, any symbol".
- **`((a|b)(a|b))*`**. ε is included because `*` allows zero repetitions.

### Worked example 2: strings over {a, b} that begin and end with the same symbol
- The trap is a **length-1** string: `a` begins and ends with `a`, so it is a member. ε has no first symbol, so I decide it is **not** a member and say so.
- Cases: just one symbol, or `a…a`, or `b…b`.
- **`a | b | a(a|b)*a | b(a|b)*b`**
- Accepted: `a`, `aba`, `bb`. Rejected: `ab` (ends differently), `ba`, ε (my stated decision).

### Worked example 3: even decimal numbers with no leading zeros
- Cases: the number `0` alone; a one-digit even number; a longer number, which starts with 1–9 and ends with an even digit.
- **`0 | [2468] | [1-9][0-9]*[02468]`**
- Accepted: `0`, `8`, `120`. Rejected: `01` (leading zero), `3` (odd), `-2` (no sign in this language).
- The "no leading zeros" pattern `0 | [1-9][0-9]*` comes back in A1.1(d). It is also our `INT_LIT` rule in `docs/LANGUAGE.md`.

### A1.2: "describe L(R) in English"
Read the regex **from the outside in**, then say what the strings *are*, not how the regex is built.
- `(a|b)*abb` → bad: "a or b repeated, then abb". Good: "**all strings over {a, b} that end in `abb`**". Accepted: `abb`, `aabb`, `babb`. Rejected: ε, `ab`, `abba`.
- For a regex with escapes (`\\`, `\.`), first say in words what each escape matches, then describe the whole string.

### Common mistakes
- Forgetting that `*` includes ε (so `a*` accepts the empty string).
- Using `.` when you mean a **literal** dot. In Flex and Python, the literal dot is `\.`.
- "Rejected" strings that use symbols outside Σ (e.g. `c` over {a, b}). They are correct but show nothing, so pick near-misses instead.
- For a "no leading zeros" rule, forgetting that `0` by itself must still be accepted.

### Check your own answers with Python (allowed: it checks *your* work)
```python
import re
R = r'((a|b)(a|b))*'                       # your regex, in Python syntax
for s in ['', 'ab', 'bbaa', 'a', 'aba']:   # your accepted + rejected strings
    print(repr(s), bool(re.fullmatch(R, s)))
```
In Python syntax, write ε as an empty alternative (`(a|)`) or with `?`, and a literal dot as `\.`.

### Practice (try first, then open)
1. Over {a, b}: every `a` is immediately followed by a `b`.
2. Over {0, 1}: contains at least two `1`s.
3. 24-hour times `hh:mm` (`00:00` to `23:59`).
4. Version numbers `1.2` or `1.2.3`; each part is `0` or has no leading zero.
5. Describe in English: `[+-]?[0-9]+`

<details><summary>Answers</summary>

1. `(b|ab)*`. It accepts ε, `b`, `abab`, `babb` and rejects `a`, `aa`, `ba`.
2. `0*10*1(0|1)*`. It accepts `11`, `0101`, `1110` and rejects ε, `0`, `1000`.
3. `([01][0-9]|2[0-3]):[0-5][0-9]`. It rejects `24:00`, `9:30` (needs 2 digits), `12:60`.
4. With N = `(0|[1-9][0-9]*)`: `N\.N(\.N)?`. It rejects `1`, `01.2`, `1.2.3.4`.
5. "Integers written in decimal, with an optional `+` or `-` sign in front; leading zeros are allowed." It accepts `7`, `-42`, `+007` and rejects ε, `-`, `4-2`.
</details>

---

## 3. A2: drawing finite automata

The question says "NFA **or** DFA", so you may choose. An NFA is usually easier to draw. But there is one case where you **need** a DFA: when the language says "does **not** contain".

### Technique 1: "contains w" (with an NFA)
Stay in the start state for as long as you like, "guess" where `w` begins, read `w`, then stay in the accepting state. Example: **contains `abb`** over {a, b}:
```
     a,b                                 a,b
     ┌─┐                                 ┌─┐
     ▼ │                                 ▼ │
 →  (0) ──a──► (1) ──b──► (2) ──b──► ((3))
```
**Chaining conditions:** if a language says "first X, later Y", draw the part for X, then the part for Y. Use a looping state in between for "anything in the middle".

### Technique 2: "contains w" as a DFA (needed before complementing)
Each state remembers **how much of `w` you have just matched**. On a wrong symbol, don't just go back to 0: go to the **longest end of what you have read that is still a start of `w`**. Contains `abb`:

| state | meaning | a | b |
|---|---|---|---|
| →0 | nothing matched | 1 | 0 |
| 1 | just read `a` | 1 | 2 |
| 2 | just read `ab` | **1** (`aba` ends in `a`, a start of `abb`) | 3 |
| *3 | found `abb` | 3 | 3 |

### Technique 3: "does NOT contain w" (complement)
Take a **complete DFA** for "contains w" and **swap** accepting and non-accepting states. For "does not contain `abb`": accept {0, 1, 2}, and 3 becomes a dead state.

⚠️ This only works on a **DFA with every transition present**. If you swap the states of an NFA, the result is wrong. In the NFA above, the swapped version would still accept `abb` by staying in state 0.

### Technique 4: counting modulo m
"The number of `a`s mod 3" needs 3 states, labeled 0, 1, 2. Reading an `a` moves to the next state (2 → 0 wraps around), and other symbols loop in place.
```
            b           b           b
           ┌─┐         ┌─┐         ┌─┐
           ▼ │         ▼ │         ▼ │
   →  ((0)) ──a──►  (1) ──a──►  (2)
        ▲                           │
        └────────────a──────────────┘
```
(This one accepts "#a mod 3 = 0", so state 0 is the accepting state.)

### Technique 5: product construction (two conditions at once)
Run two DFAs **side by side**. A product state is a **pair** (state of DFA 1, state of DFA 2), and each symbol moves both parts at once. Which pairs accept depends on the condition:
- **AND**: both parts accept.
- **OR**: at least one part accepts.
- **Any other relation between them** (equal, different, …): mark exactly the pairs that satisfy it.

The number of states is (states of DFA 1) × (states of DFA 2).

Worked example: **even length AND contains at least one `b`**, over {a, b}. DFA 1 tracks length parity, E/O. DFA 2 tracks whether a `b` was seen, N/Y.

| state | a | b |
|---|---|---|
| →(E,N) | (O,N) | (O,Y) |
| (O,N) | (E,N) | (E,Y) |
| *(E,Y) | (O,Y) | (O,Y) |
| (O,Y) | (E,Y) | (E,Y) |

Check: `ab` goes (E,N) → (O,N) → (E,Y), accepted ✓. `aa` ends in (E,N), rejected ✓. `b` ends in (O,Y), rejected ✓.

Tip for A2: decide which techniques each language needs before drawing anything. One language may need two of them combined.

### Always test your automaton
Trace 3 accepted and 3 rejected strings through your drawing. Also count the arrows: in a complete DFA, every state has exactly one arrow per symbol.

### Practice
1. DFA over {a, b}: ends with `ab`.
2. DFA over {a, b}: does **not** contain `aba`.
3. DFA over {a, b}: even number of `a`s AND odd number of `b`s.

<details><summary>Answers</summary>

1. States 0 (nothing), 1 (just read `a`), 2 (just read `ab`, accepting). 0: a→1, b→0 · 1: a→1, b→2 · 2: a→1, b→0.
2. First build "contains `aba`": 0: a→1, b→0 · 1: a→1, b→2 · 2: a→3, b→0 · 3: a,b→3. Then swap: accept {0, 1, 2}; 3 is dead.
3. Product of (a parity) × (b parity) = 4 states (Ea,Eb) (Ea,Ob) (Oa,Eb) (Oa,Ob). `a` flips the first part, `b` flips the second. Start (Ea,Eb), accept only (Ea,Ob).
</details>

---

## 4. A3: Thompson's construction

Thompson's construction turns **any** regex into an NFA. It uses 5 small "Lego pieces" and snaps them together **bottom-up**, following the regex's structure. Each piece has exactly **one start** and **one final** state. This is the version in the lecture (Thain ch. 3, and the Cooper & Torczon summary figure in lecture 3).

### The 5 rules
```
1) symbol a:          (i) ──a──► (f)

2) ε:                 (i) ──ε──► (f)

3) concatenation AB:  [ A ] ──ε──► [ B ]
                      start = A's start,  final = B's final

4) union A|B:              ┌──ε──► [ A ] ──ε──┐
                       (i)─┤                  ├─►(f)
                           └──ε──► [ B ] ──ε──┘

5) star A*:                    ┌────ε (back)────┐
                               ▼                │
                    (i) ──ε──► [       A       ] ──ε──► (f)
                     │                                   ▲
                     └──────────ε (skip, zero times)─────┘
```
**Derived rules:** `A+` = `AA*` (build A, build A*, concatenate them) · `A?` = `A|ε` · a character class like `[0-9]` = **one** arrow labeled `0-9`, the way Flex treats it. Write "let d = [0-9]" on your page so the grader sees you meant it. A literal `\.` is a single symbol, the dot.

### Worked example: `ab*|c`
**Step 0: draw the parse tree first.** It is `|` with children `a·b*` and `c`, and `a·b*` is concatenation with children `a` and `b*`. Build from the **leaves up**, numbering states in the order you create them.

1. `a`: 1 ──a──► 2
2. `b`: 3 ──b──► 4
3. `b*`: new states 5 and 6. 5 ──ε──► 3, 4 ──ε──► 3 (back), 4 ──ε──► 6, 5 ──ε──► 6 (skip). It starts at 5 and ends at 6.
4. `a·b*`: 2 ──ε──► 5. It starts at 1 and ends at 6.
5. `c`: 7 ──c──► 8
6. `(a·b*) | c`: new states 9 and 10. 9 ──ε──► 1, 9 ──ε──► 7, 6 ──ε──► 10, 8 ──ε──► 10. **Start 9, final 10.**

Final NFA (10 states):
```
                ┌──ε──► 1 ──a──► 2 ──ε──► 5 ──ε──► 3 ──b──► 4 ──ε──► 6 ──ε──┐
                │                         │        ▲        │         ▲     │
   → 9 ─────────┤                         │        └───ε────┘         │     ├──► ((10))
                │                         └─────────────ε─────────────┘     │
                └──ε──► 7 ──c──► 8 ──ε──────────────────────────────────────┘
```

**Self-check by counting states:** every symbol adds 2 states, every `*` adds 2, every `|` adds 2, and concatenation adds 0. Here that gives a, b, c (6) + one star (2) + one union (2) = **10** ✓. Count the same way for your own answers.

**How to present it** (FAQ: "show base cases, combination, final NFA"): draw each base piece, then each combination step with its new states labeled, then the final NFA. One small drawing per step is clearer than one big crowded drawing.

### Common mistakes
- Forgetting the **skip** arrow in a star, so zero repetitions are impossible.
- Forgetting the **back** arrow, so only one repetition is possible.
- Merging states to "save space". Thompson's construction never merges; that is what minimization is for (A4).
- Building `A+` as `A*`, which wrongly allows zero repetitions.

### Practice
1. `(ab)+`
2. `x?y`
3. `[a-c]*`

<details><summary>Answers (state counts)</summary>

1. `(ab)+` = `(ab)(ab)*`: 4 symbols (8) + one star (2) = **10 states**.
2. `(x|ε)y`: x (2) + ε (2) + union (2) + y (2) = **8 states**.
3. One `a-c` arrow (2) + star (2) = **4 states**.
</details>

---

## 5. A4.1: subset construction (NFA → DFA)

**Idea:** an NFA can be in **several states at once**. A DFA state is the **set** of NFA states the NFA could be in at that moment.

### The algorithm
1. **Start state** of the DFA = ε-closure(NFA start), meaning the start state plus everything reachable from it by ε-arrows only.
2. For each new DFA state S and each symbol x: collect every NFA state reachable from a member of S by one x-arrow, then take the ε-closure. That set is the target state.
3. If the target set is new, give it a name (A, B, C…) and add a row to the table. Repeat until no new sets appear.
4. A DFA state is **accepting** if its set contains **any** accepting NFA state.
5. If a target set is **∅** (no move possible), it is the dead state. Either write it as a row with self-loops, or note "missing arrows go to the dead state ∅".

### Worked example (no ε): "the second-to-last symbol is `a`"
NFA over {a, b}, start 0, accept {2}: δ(0,a) = {0,1}, δ(0,b) = {0}, δ(1,a) = {2}, δ(1,b) = {2}.

| DFA state | NFA set | a | b | accepting? |
|---|---|---|---|---|
| →A | {0} | {0,1} = B | {0} = A | no |
| B | {0,1} | {0,1}∪{2} = {0,1,2} = C | {0}∪{2} = {0,2} = D | no |
| *C | {0,1,2} | {0,1}∪{2}∪∅ = C | {0}∪{2}∪∅ = D | **yes** (contains 2) |
| *D | {0,2} | {0,1}∪∅ = B | {0}∪∅ = A | **yes** (contains 2) |

Check with strings: `ab` goes A→B→D, accepted ✓. `ba` goes A→A→B, rejected ✓.

Then **draw** the final DFA, with states A–D, start arrow, double circles and all arrows. The question asks for the named subsets, the complete table, the accepting states and the diagram, so include all four.

### Worked example (with ε): the Thompson NFA of `ab*|c` from §4
- Start = ε-closure(9) = **{1, 7, 9}** = S0
- S0 on `a`: 1→2, closure of {2} = 2→5→{3, 6}→10 = **{2, 3, 5, 6, 10}** = S1 (accepting, contains 10)
- S0 on `c`: 7→8, closure = **{8, 10}** = S2 (accepting)
- S0 on `b`: no arrows → ∅ (dead)
- S1 on `b`: 3→4, closure = **{3, 4, 6, 10}** = S3 (accepting) · S1 on `a`, `c`: ∅
- S3 on `b`: 3→4 → S3 again · S2 on anything: ∅

The result is a DFA with 4 live states: S0 –a→ S1, S0 –c→ S2, S1 –b→ S3, S3 –b→ S3.

### Common mistakes
- Forgetting the ε-closure **after** each move.
- Forgetting to check that a "new" set isn't one you already named. {0,2} and {2,0} are the same set.
- Marking accepting states wrongly. The rule is "the set contains an NFA accepting state".

### Practice
NFA over {a, b}: start 0, accept {1}. δ(0,a) = {0,1}, δ(0,b) = {1}, δ(1,b) = {0}. Build the full table.

<details><summary>Answer</summary>

A = {0}: a→{0,1} = B, b→{1} = C · B = {0,1}: a→{0,1} = B, b→{1}∪{0} = {0,1} = B · C = {1}: a→∅ = D, b→{0} = A · D = ∅: a,b→D.
Accepting: B, C (they contain 1).
</details>

---

## 6. A4.2: minimization and regex equivalence

### Hopcroft's partition refinement (the lecture's method)
**Idea:** two states are "the same" if, for **every** future input, they agree on accepting or rejecting. Start with a rough split and refine it until it is stable.

1. Make the DFA **complete**: add the dead state, with every missing arrow going to it.
2. Initial partition: **{accepting states}** and **{non-accepting states}**.
3. For each group and each symbol, check where every state in the group goes. If two states in the same group go to **different groups**, split the group.
4. Repeat step 3 until nothing splits.
5. Each final group is one state of the minimal DFA. The start state is the group that contains the old start. The accepting states are the groups made of accepting states.

### Worked example: the DFA of `ab*|c` from §5 (add dead state D)
- P0: {S1, S2, S3} (accepting) | {S0, D}
- Check {S1, S2, S3} on `b`: S1→S3 (accepting group), S2→D (non-accepting), S3→S3 (accepting). So **split** into {S1, S3} and {S2}.
- Check {S0, D} on `a`: S0→S1 (accepting), D→D (non-accepting). So **split** into {S0} and {D}.
- P1: {S1, S3} | {S2} | {S0} | {D}. Check {S1, S3}: on `a` both go to D, on `b` both go to S3, on `c` both go to D. Same groups, so it is **stable**.
- The minimal DFA has 3 live states plus the dead state: M0 –a→ M1, M1 –b→ M1 (loop), M0 –c→ M2, with M1 and M2 accepting.

### How to check whether two regexes are equivalent
1. Build a DFA for each regex: Thompson + subset construction is the safe, systematic route. A small hand-drawn NFA is also fine, as long as you show it.
2. Minimize both.
3. **Compare** them. They are equivalent if and only if the minimal DFAs are the same up to renaming the states. To test that, walk both from their start states in parallel. The pairs of states you reach must always agree on accepting, and the arrows must match.
4. If they are **not** equivalent, also give a **counterexample string** that one accepts and the other rejects. It makes the answer convincing.

Mini-example: `(a|b)*` vs `a*b*`. The minimal DFA of `(a|b)*` has **1** accepting state that loops on a and b. For `a*b*`, p (start, accepting) goes a→p and b→q; q (accepting) goes b→q and a→dead. Minimizing keeps all 3 states (p and q split on `a`). 1 state ≠ 3 states, so they are **not equivalent**. The counterexample is `ba`: `(a|b)*` accepts it, `a*b*` rejects it.

Tip: before drawing, write out the first few strings each regex generates (length 0, 1, 2, 3) to guess the answer. Then prove it with the DFAs. The question is graded on the DFAs, not on the guess.

### Practice
1. `a(ba)*` vs `(ab)*a`
2. `(a*b)*` vs `(a|b)*b | ε`

<details><summary>Answers</summary>

1. **Equivalent**. Both minimize to q0 –a→ q1 (accepting), q1 –b→ q2, q2 –a→ q1, with every other arrow going to the dead state: 3 live states + dead.
2. **Equivalent**. Both are "empty, or ends with `b`". The minimal DFA has 2 states: q0 (start, accepting) a→q1, b→q0; q1 (rejecting) a→q1, b→q0.
</details>

---

## 7. A5: short answers (3–5 sentences each)

The concepts you need. The answers are yours to write.

- **Maximal munch:** when several prefixes of the input match some rule, the lexer takes the **longest** one. **Rule priority:** when two rules match the **same** length, the rule listed first wins. Lecture 2, slides "Ambiguity". Our `docs/LANGUAGE.md` §2.5 walks through the very similar input `ifx`.
- **Minimal munch** would mean "take the **shortest** match". Before writing (a), try it yourself on `==`, `<=`, `count`, `42` and `ifcondition`. Write down which tokens you would get, and what a parser would then see.
- **BPE (byte pair encoding):** training repeatedly merges the most frequent adjacent pair into a new token, and **records the merges in order**. When tokenizing new text, the merges are applied **in that recorded order**. Lecture 3, slides "Byte-Pair Encoding" (the hug/pug/pun example) and "Ambiguity in Regex: BPE analogy". For (b), ask yourself: when two different merges could apply to the same characters, what decides which one happens? Which Flex mechanism plays the same role?

---

## 8. Before you scan: checklist

- [ ] Name + student ID on **every** page; pages numbered; question labels (A1.1(a), …) clearly visible.
- [ ] A1: every regex has 3 accepted + 3 rejected strings; edge-case assumptions written down.
- [ ] A2: start arrow, double circles, every arrow labeled; you traced at least 2 strings through each automaton.
- [ ] A3: base pieces → combination steps → final NFA, states numbered; state count checked.
- [ ] A4.1: named subsets, full table, accepting states marked, final DFA **diagram**.
- [ ] A4.2: both minimized DFAs drawn for each pair, the partition steps shown, a clear verdict, and a counterexample if not equivalent.
- [ ] A5: 3–5 sentences each.
- [ ] Scan with a document-scanner app (iOS Notes "Scan Documents", Adobe Scan) → **one** PDF; zoom in to check it is readable.

---

## 9. How Claude can help (and what it won't do)

**Ask for this any time:**
- "Check my A2(b) automaton": take a photo, then paste the image file path into the chat (Claude Code can read images), or type the transition table. I'll trace strings through it and point out errors, without rewriting it for you.
- "Give me 3 more practice problems like A4.2", "explain ε-closure again", "quiz me on Thompson's rules".
- "Is my regex for A1.1(d) right?" I'll test it against edge cases and tell you which strings break it.

**What I won't do:** write the final answers to the graded questions. Part A is individual, handwritten work, and the professor may question you on it live.
