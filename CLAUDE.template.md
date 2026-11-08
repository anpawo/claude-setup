## Work inside the project's folder

- My projects live in `__PROJECTS_DIR__`: one folder per project, each one its own git repo on GitHub.
- Right after my first prompt, as soon as you know which project the task is about, run `cd <that project's root folder>` as a command on its own (not chained with `&&`), then work from there. A later task on another project starts with a new `cd`. A task that is not about one project stays in the folder the session started in.
- A new project gets a new folder in `__PROJECTS_DIR__`, never files dropped loose in the projects folder or in `~`.

## Always committed and pushed to GitHub

- Every project folder is a git repo with a GitHub remote. If it is not one yet, set it up before the first edit: `git init`, then `gh repo create <folder name> --private --source . --push`.
- After each change that works (it builds, the tests pass), commit only the files you changed, with a message that says why, then `git push`. A task is not finished while something is uncommitted or unpushed: the status line shows `uncommitted` or `unpushed` when that is the case.
- Never `git push --force`, never rewrite history. Never commit secrets (`.env`, keys, tokens): put them in `.gitignore` first.
