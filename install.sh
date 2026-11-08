#!/usr/bin/env bash
# Installs the skills, the status line, the startup defaults and the CLAUDE.md rules into ~/.claude.
# Run it again any time: it overwrites the skills and the status line, and keeps your other settings.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
C="$HOME/.claude"

for tool in jq git gh; do
  command -v "$tool" >/dev/null || { echo "Missing $tool: see the install steps in README.md"; exit 1; }
done
gh auth status >/dev/null 2>&1 || echo "Note: run 'gh auth login' once so Claude can create and push GitHub repos."

read -r -p "Folder that holds your projects [~/Projects]: " projects
projects="${projects:-~/Projects}"
mkdir -p "${projects/#\~/$HOME}" "$C/skills"

cp -R "$here/skills/." "$C/skills/"
cp "$here/statusline.sh" "$C/statusline.sh"
chmod +x "$C/statusline.sh"

# Startup defaults: Opus, high effort, no permission prompts, the status line.
s="$C/settings.json"
[ -f "$s" ] || echo '{}' > "$s"
jq '. + {
      model: "opus",
      effortLevel: "high",
      skipDangerousModePermissionPrompt: true,
      statusLine: {type: "command", command: "bash ~/.claude/statusline.sh", refreshInterval: 5}
    }
    | .permissions.defaultMode = "bypassPermissions"' "$s" > "$s.tmp" && mv "$s.tmp" "$s"

# CLAUDE.md rules, added once.
if ! grep -q "Work inside the project's folder" "$C/CLAUDE.md" 2>/dev/null; then
  { [ -s "$C/CLAUDE.md" ] && echo; sed "s|__PROJECTS_DIR__|$projects|g" "$here/CLAUDE.template.md"; } >> "$C/CLAUDE.md"
fi

# ponytail plugin: pushes Claude toward the simplest code that works.
claude plugin marketplace add DietrichGebert/ponytail >/dev/null 2>&1 || true
claude plugin install ponytail@ponytail >/dev/null 2>&1 || echo "Could not install ponytail, run: claude plugin install ponytail@ponytail"

echo "Done. Skills: $(ls "$C/skills" | tr '\n' ' ')"
echo "Start a new 'claude' session to load everything."
