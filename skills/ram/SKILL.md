---
name: ram
description: >
  RAM checkup of this computer (macOS, Linux or Windows): memory use and swap, memory by app,
  each Claude Code session with what it started (MCP servers, browsers, dev servers), and
  leftovers whose session is gone, which it stops. Use when the user asks about RAM or memory,
  why the computer is slow or swapping, or what eats memory. Triggers: "/ram", "ram check",
  "check the RAM", "what's eating my RAM", "memory check", "my computer is slow".
---

# ram: what holds the memory, and what can go

1. **Measure.** Run the script for this system:
   - macOS or Linux: `bash ~/.claude/skills/ram/ram.sh`
   - Windows: `powershell -NoProfile -ExecutionPolicy Bypass -File ~/.claude/skills/ram/ram.ps1`

   It prints four blocks: memory (use, swap or page file, and on macOS the kernel's pressure
   level), memory by app, Claude sessions (claude's own GB, GB of what it started, age, name,
   `rc` for Remote Control, `-p` for a headless job, folder), and leftovers (MCP servers or
   headless browsers whose parent is gone).
2. **Stop the leftovers**: `kill <pid>` (Windows: `Stop-Process -Id <pid>`). They belong to a
   session that no longer exists, so nothing is lost. A `-p` job that has run for hours is a
   leftover too: read its folder and what launched it before stopping it. Nothing else is
   stopped: the user's apps and sessions are theirs; for those, recommend.
3. **Reply.**
   - First line: memory used, swap or page file used, and on macOS the pressure level (`1`
     fine, `2` tight, `4` critical).
   - Memory figures in GB with one decimal (0.3 GB), never MB.
   - A table of the top apps by memory, Claude Code and its MCP servers on their own rows.
   - The sessions only when they matter: a session whose "started" column is large (a dev
     server, a browser) or `-p` jobs piling up.
   - What was stopped, in one line. Then the one action that frees the most, with its figure
     (quit an app, end a finished Claude session).

Open no window (Activity Monitor, Task Manager): everything here is read from the shell.
