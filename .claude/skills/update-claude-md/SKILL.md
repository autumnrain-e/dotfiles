# update-claude-md

Invoked by the user with `/update-claude-md` after changes have been made to the dotfiles configuration.

## What to do

1. Read the current `CLAUDE.md`.
2. Run `git diff HEAD` and `git status` to understand what changed.
3. Read any relevant config files that were modified.
4. Update `CLAUDE.md` so it matches the current state of the repo.
5. Remind the user to also run `/update-readme` if the changes should be visible in the public-facing README.

## What CLAUDE.md covers — and what it does not

CLAUDE.md is the **structure and how-to-operate** layer: stow packages, config languages, the
active theme and fonts, what each package contains, which aliases and commands reload each tool,
workflow rules, git conventions.

It does **not** hold reasons, rejected alternatives or traps. Those belong in the memory files
(`.claude/memory/MEMORY.md` and the `MEMORY-<domain>.md` files) via the `memory-log` skill. If you
find yourself writing "because", "verified", "the trap is", or a dated observation into CLAUDE.md,
it is memory content — put it there and leave at most a pointer.

## Rules

- CLAUDE.md is **AI-facing** — precise file paths, option names, current values.
- Never copy an invariant from a memory file into CLAUDE.md; point at the domain file instead.
  One home per fact is what stops the two from drifting.
- If a new stow package is added, add it to the Structure list and give it a short section
  following the existing pattern.
- If the active colorscheme changed, update the Theme & Appearance section and every other mention.
- Keep the Memory Protocol section's domain-file list in sync with `.claude/rules/memory.md`.
- Do not remove the Fastfetch rebuild instructions or the secrets.fish warning.
