---
name: mk
description: >
  md-kill. Writes what this session learned and left into one markdown file in the project the
  session works on, then ends this Claude session and closes its terminal tab. Use when the user wants
  the session's knowledge kept as a note in the project before closing. Triggers: "/mk", "mk",
  "md kill", "note it in a .md and close".
---

# mk: note to .md, kill

Do the steps in order. Anything that fails before the last step stops the skill: one line, kill nothing.

0. **Done?** Same test as `ck` step 0 (`~/.claude/skills/ck/SKILL.md`): nothing of this session
   still runs whose result is needed (agent, detached run, build), and no question to the user waits.
   Not done: one line saying what is left, write nothing, kill nothing.
1. **Where.** The project root the session works on: its git root (`git rev-parse --show-toplevel`),
   or the folder of its standalone `cd`. A team repo where a personal note does not belong (its
   own `AGENTS.md` rules, shared with other people) takes the note in the parent folder the user owns
   when there is one; say which.
2. **Write.** One file, `<TOPIC>.md` in caps kebab case named after the session's subject (e.g.
   `GLIMPSE-NOTES.md`); an existing file of that name is read whole and updated, never duplicated.
   English. What the user will need again, read off the session, not recalled:
   - the subject in two lines and the current state (what works, what is left, open PRs or todos);
   - facts the user asked about, as tables where they compare;
   - every command the user will rerun, exact, in code blocks;
   - links (full `https://` URLs, absolute file paths).
   No session narrative, no "I did".
3. **Commit only where the repo says so.** A repo with `.autocommit`: commit that one file
   (`git commit -m … -- <file>`) and push. Otherwise leave it uncommitted and say so.
4. **Kill.** Print one line: `<file path> written` (plus `committed <hash>` when it was), then run
   `~/.claude/skills/ck/kill.sh` as the very last tool call. Nothing written after it is read.
