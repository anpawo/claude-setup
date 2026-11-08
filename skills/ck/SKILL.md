---
name: ck
description: >
  commit-kill. Asks the session whether its work is done; if it is, commits and pushes the repo the
  session is in, then ends this Claude session and closes the terminal tab it runs in. Not done: says
  what is left and closes nothing. Triggers: "/ck", "ck", "commit kill", "commit-kill".
---

# ck — done?, commit, push, kill

Do the steps in order. Anything that fails before the last step stops the skill: report
in one line, kill nothing.

0. **Done?** Answer it from this session's own work, before touching git. Done is all three:
   - what the user asked last is finished and checked: the command that proves it has run and passed,
     or the reply said what could not be proven;
   - nothing of this session still runs whose result is needed: no background agent, detached
     run, Monitor or build;
   - no question to the user waits for its answer, and the last reply announced no step the session
     was going to take itself.

   A next action left to *the user* (look at a render, press a key, try it live) does not count
   against done. Not done → one line: what is left and who it waits on; commit nothing, kill
   nothing, stop.
1. **Commit.** `git status --porcelain` in the current directory. Not a repo → skip straight to the kill.
   Only this session's files go in: the paths its own Edit and Write calls touched and the files its
   commands wrote, kept if `git status` lists them. Another session may work in the same tree, and
   what it changed or staged is its own: never `git add -A`, never commit the shared index. None of
   them listed → skip to the push. Otherwise, in one command, `git add -- <its new files>` then
   `git commit -m … -- <its paths>`, which takes those paths alone, whatever else is staged. Title:
   one sentence in the repo's own style (read `git log --oneline -5`), written from the diff of those
   paths, ending with the `Co-Authored-By` trailer the session already uses. Then
   `git show --name-status HEAD`: anything listed that is not its own → stop, nothing pushed. A file of
   its own that holds another session's hunks too stays out, named in the summary.
2. **Push.** `git push`, or `git push -u origin <branch>` when the branch has no upstream.
   Rejected push → stop and say why; the commit stays local.
3. **Kill.** Print the one-line summary (`<hash> pushed to <remote>/<branch>`, with `<n> changed files left to
   other sessions` when `git status` still lists some, or `not a repo — nothing to commit`), then run
   `~/.claude/skills/ck/kill.sh` as the very last tool call. It ends the `claude` process and
   the shell above it a second later, and Ghostty closes the surface on its own (in Vibe Code X,
   which has no shell above Claude, VCX closes the window when Claude exits). Nothing you
   write after it will be read.

`kill.sh --dry-run` prints the pids it would signal without signalling them.
