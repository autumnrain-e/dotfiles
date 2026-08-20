# update-claude-md

Invoked by the user with `/update-claude-md` after changes have been made to the dotfiles configuration.

## What to do

1. Read the current `CLAUDE.md`.
2. Run `git diff HEAD` and `git status` to understand what changed.
3. Read any relevant config files that were modified.
4. Update `CLAUDE.md` to accurately reflect the current state, rules, and conventions of the repo.
5. Remind the user to also run `/update-readme` if the changes should be visible in the public-facing README.

## What CLAUDE.md covers

- Repo structure (stow packages)
- Theme & appearance (active colorscheme, per-tool details, fonts)
- Neovim details (plugin list, key plugin files and their purpose, LSP, Treesitter)
- Yazi details (flavor, theme.toml overrides, known quirks)
- Shell configuration (Fish aliases, environment tools, secrets handling)
- Fastfetch details (custom fork, rebuild instructions)
- Workflow rules (conventions, what to keep in sync)
- Testing changes (how to reload each tool)
- Git conventions
- AI assistant notes (reference to lessons.md)

## Rules

- CLAUDE.md is **AI-facing** — be precise, include file paths, option names, and known gotchas.
- Document the *why* behind non-obvious config choices (e.g. why a specific glyph must be written via Python).
- If a new tool is added, create a new section following the existing pattern.
- If the active colorscheme changed, update the Theme & Appearance section and every other mention.
- Always keep the reference to `.claude/tasks/lessons.md` in the AI Assistant Notes section.
- Do not remove the Fastfetch rebuild instructions or the secrets.fish warning.
