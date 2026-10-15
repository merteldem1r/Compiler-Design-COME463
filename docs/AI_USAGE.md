# AI Usage Log

Course policy: AI use must be acknowledged in every report, with **2–3 prompts verbatim** and **what the AI got wrong and how it was fixed**. Append entries as we go; the reports quote from here.

**Tool:** Claude Code (Anthropic, model Claude Opus 5.5), used in this repository.

| Date | Milestone | What the AI did | Notable prompt (verbatim, or "see below") | What it got wrong → fix |
|---|---|---|---|---|
| 2026-10-14 | P1 | Analyzed lecture notes, wrote the roadmap and plan, set up the repo | P-1 | Assumed the directive file had content; it was empty on disk. Fetched the official text from the professor's GitHub instead |
| 2026-10-14 | P1 | Wrote the repo rules and git guard; split `CLAUDE.md` into a map + rule files | P-2, P-3 | The first `/wrap-up` skill committed to git by itself, against the student's wish to run git personally. Rewritten to only print the commands; `settings.json` now denies git writes |
| 2026-10-14 | P1 | Ran the language design as multiple-choice rounds, explained the cost of each feature across P1–P4, and wrote `docs/LANGUAGE.md` | P-4 | (1) Offered the `..` range token separately from the `for` loop; the student picked `..` without `for`, which would have left a token with no use. The AI caught it and asked again. (2) Float regex `[0-9]+\.[0-9]+` accepts `007.5`, contradicting the "no leading zeros" rule for ints; found in review, fix pending. (3) Didn't rename "MiniLang" to Anka in `ROADMAP.md`; fixed later |
| 2026-10-14 | P1 | Status analysis; rebuilt the lost session log from the transcript; wrote the `SessionStart` wrap-up check hook | P-5, P-6 | No wrong output caught. Known limitation, accepted: the hook warns about *any* commit made after the last log commit, so a small typo-fix commit also triggers a "missed wrap-up" note |
| 2026-10-15 | P1 | Built the lexer (`tokens.h`, `lexer.l`, `main.c`, `Makefile`), the Part A study guide and the lexer walkthrough page | — | Spec v0.1 (written by the AI) said **15** keywords and **10** multi-char operators; the real counts are **16** and **13**. Caught while counting the 62 rules in the generated `lex.yy.c`; fixed in `LANGUAGE.md`, `tokens.h` and the walkthrough |

## Prompts (verbatim)

**P-1 (2026-10-14):**
> analyze the current project structure, first please read the docs/ folder … Also, point out which PDF from the lecture notes I should review, analyze, and read to understand the topic. Then, please write a small roadmap or some kind of plan somewhere. … Also, what kind of language, tools, or tech stack should we pick?

**P-2 (2026-10-14):**
> could you add memory for this repository, first one is that after each change you are going to explain in human understandable way what how done 2-3 paragraph, then if there is changes, show the git add  and git commit commands on the chat so I can do the git commands by my own, also never commit anything by your own, add those rules into the repositoty on proper folder with the best practices

**P-3 (2026-10-14):**
> let's make the claude.md file as the starting point where in general stuff are located, the locations, folders, etc. no need to add the rules one by one to the claude.md I guess, since we have the proper rules folder now, please follow the best practices of repository structure, so every claude sessino have brief understanging about the project, current structure, where and what located, how to work in that repo, which rules and general implementation should follow, let's make it professional and efficient

**P-4 (2026-10-14):**
> let's pick it together, ask me questions and give me the interesting options

**P-5 (2026-10-14):**
> analyze the project, on which stage/phase we are right now, what is the next step

**P-6 (2026-10-14):**
> besides that how the skill currently works, on the previous sessoin I've just ended the session via exit command but no session or AI usage are actually written, is that normal, is there is hook that should make that
