# update-readme

Invoked by the user with `/update-readme` after changes have been made to the dotfiles configuration.

## What to do

1. Read the current `README.md`.
2. Run `git diff HEAD` and `git status` to understand what changed.
3. Read any relevant config files that were modified (colorscheme, plugin list, shell aliases, etc.).
4. Update `README.md` to accurately reflect the current state of the repo.
5. Remind the user to also run `/update-claude-md` if the changes affect how Claude should work with this repo.

## What README.md covers

- Tools table (terminal, shell, editor, file manager, prompt, etc.)
- Theme & appearance (active colorscheme, font, per-tool details)
- Repo structure (stow package → path mapping)
- Installation instructions
- Per-tool sections: Neovim plugins, Fish aliases, Fastfetch rebuild, Yazi theming notes

## Rules

- The README is **user-facing** — keep it clean, accurate, and human-readable. No internal implementation detail unless it's useful for someone setting up the dotfiles fresh.
- Do not add sections for things that aren't configured yet.
- Keep the tone consistent with the existing file: concise, table-heavy, minimal prose.
- If the active colorscheme changed, update every mention of the old theme.
- Do not remove the Fastfetch rebuild instructions — they are important for fresh setups.
