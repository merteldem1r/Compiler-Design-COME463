# Workflow rules (set by the student, always apply)

## 1. Explain every change in plain words

After **every** change to the repo (code, docs, config), end the reply with a short explanation of **2–3 paragraphs** written for a student, not an expert:

- **What** changed and which files.
- **How** it works: the idea behind the code, linked to the lecture concept where there is one (maximal munch, rule priority, NFA/DFA, …).
- **Why** it was done this way, and anything the student should be ready to explain in class.

No jargon without a one-line definition. The student must be able to defend every line live, so the explanation is part of the deliverable.

## 2. Never run git write commands, only show them

- **Never** run `git add`, `git commit`, `git push`, `git tag`, `git reset`, `git rebase`, or anything else that changes git history or the index. `.claude/settings.json` blocks the main ones as a hard guard.
- Read-only git is fine: `git status`, `git diff`, `git log`, `git show`.
- When files changed, finish the reply with a ready-to-paste block for the student to run:

```bash
git add <the specific files that changed>
git commit -m "<type>: <short summary>" 
```

- List files explicitly; avoid `git add -A` unless every change belongs in the commit.
- Message style: `docs:`, `feat:`, `fix:`, `test:`, `chore:` prefix, under 72 characters, imperative mood ("add lexer rules", not "added").
- If nothing changed, say so and show no git block.
