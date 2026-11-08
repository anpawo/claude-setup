---
name: santa
description: Adversarial review by three independent reviewers before a deliverable leaves the machine. All three must pass; otherwise fix and rerun, three rounds max. Runs on its own before anything is sent to a human (mail, ticket, note to a teacher or jury, portfolio page, CV, release) and on request. Triggers: "/santa", "santa", "check it twice", "review before sending", "relis avant d'envoyer".
---

# Santa: make a list, check it three times

An agent reviewing its own work has the blind spots that produced it. Three reviewers with a
fresh context, who do not see each other, using the same checklist, break them. **All three must
pass.** One FAIL is enough: the defect is real, and the other two missing it is exactly what Santa
exists to catch.

## When it runs

- **On its own**, right before a deliverable goes to a human: a mail or ticket sent in the user's
  name, a note to a teacher or jury, a portfolio page, a CV, a release, a shared document.
- **On request**: `/santa <file or text>`.
- **Never** for an internal draft, an exploration, or what a build, test or lint already checks better.

One line before starting: "santa, 3 reviewers, on <what>". It costs three agents.

## Protocol

1. **Checklist first.** Write 4 to 8 criteria, each with an objective PASS condition. Common base:
   factual accuracy (every figure, name, commit, version checks out in the repo or the source), no
   invention (URL, quote, API, file), completeness (every requested point is there), internal
   consistency, correct language for the recipient, tone fit for the recipient. Add domain criteria:
   license, security, numbers.
2. **Three reviewers in parallel**, `Agent` x 3, `subagent_type: general-purpose`, model sonnet, in
   the same message so they run together. Each gets: the original request, the deliverable, the
   checklist, file access to verify, and this instruction:

   You are an independent reviewer. You have seen no other review. For EACH criterion, check it
   yourself (read the files, run grep) and return PASS or FAIL with the evidence. Your job is to
   find problems, not to approve. Answer in JSON:
   {"verdict":"PASS|FAIL","checks":[{"criterion":"...","result":"PASS|FAIL","detail":"..."}],
   "critical_issues":["..."],"suggestions":["..."]}

3. **Verdict.** PASS PASS PASS: NICE, it ships. Otherwise NAUGHTY: merge the three
   `critical_issues`, deduplicate.
4. **Fix** only what was flagged (no rewrite, no additions), then run **three fresh reviewers**
   (never the same agents: they would remember).
5. **Three rounds max.** Still NAUGHTY after three: do not send, show the user the remaining
   issues, the user decides.

## What the user sees

One line per round: `santa round 1: FAIL FAIL PASS, 2 defects: ...`, then `santa: NICE, 3/3`.
The JSON stays in the tool calls. `suggestions` do not block: mention them in one line if they are
worth it, otherwise drop them.
