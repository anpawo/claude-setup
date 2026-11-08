---
name: grill
description: Grills the user on a plan, a design or a decision, one round of numbered questions at a time, each with my recommended answer, until nothing is left assumed; nothing is built before the user says we agree. Use when the user says grill. Triggers: "grill".
---

# grill

Map the decision as a tree: each choice opens the choices that hang off it. Work it in rounds.

- **A round is the frontier**: every question whose prerequisites are settled, asked together. A question that depends on one still open in this round waits for a later round. At most 5 a round; past that, the 5 that unblock the most.
- **Facts are mine, decisions are the user's.** A question the user could only answer by looking something up is not asked: I read the code, the data, the logs (a subagent if it is long; the questions that do not depend on it go out now). Each option carries its measured cost or effect (minutes, files touched, how many cases it changes), read off the running thing.
- **Each question ends with my answer** and why, in one sentence. 2 to 4 options, mine first.
- **The answer reshapes the tree**: drop the branches it closes, recompute the frontier, ask the next round. An answer that questions the premise ("why does it do X at all?") goes back to the facts first, then to the round.
- **Done** when the frontier is empty: what was decided in at most 5 bullets, and nothing built until the user confirms.

A round looks like this:

```
❓ **Q1** - **<title>**: <the question, its options with their cost>

➡️ <my answer, and why in one sentence>

---

❓ **Q2** - ...
```
