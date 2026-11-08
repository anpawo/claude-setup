---
name: wtd
description: What to do — the state of a project in one icon table — ✅ done / 🟠 in progress / ❌ to do or broken. Triggers: "/wtd", "wtd", "what to do", "table todo", "what works and what doesn't", "où on en est", "status table".
---

# wtd

One markdown table, nothing else. No sentence before, no sentence after, no "next steps".

| Column | Content |
|---|---|
| Item | short name of the piece (file, feature, errand) |
| Status | `✅` done and verified · `🟠` in progress / not wired yet / not verified · `❌` to do, broken, or blocked |
| Note | ≤ 8 words: what is missing or what blocks. Empty if ✅ |

Rules:
- Read the real state (files, tests, logs, processes) before writing; never from the conversation's memory alone.
- `✅` only if verified in the session (green test, output seen). Written but never run = `🟠`.
- Sort: ❌ first, then 🟠, then ✅.
- One row per piece, no sub-tables, no sections. If the user gives a scope (`/wtd recon-v3`), keep to it.
