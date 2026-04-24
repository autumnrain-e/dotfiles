# update-lessons

Invoked by the user with `/update-lessons` after a session where something was tried, failed, and then fixed.

## What to do

1. Read `.claude/tasks/lessons.md` to understand the existing format and avoid duplicating entries.
2. Look back at the current conversation and identify:
   - What was the original goal
   - What was attempted and failed (include the specific wrong approach)
   - What the root cause turned out to be
   - What the final working fix was
3. Append a new section to `.claude/tasks/lessons.md` following the format below.
4. Do not rewrite or reformat existing entries — only append.

## Entry format

```markdown
### <Tool/Area> — <short description of the problem>
- **Problem**: What the user was trying to achieve and what went wrong.
- **What failed**: The specific approach(es) that did not work and why.
- **Root cause**: The actual underlying reason.
- **Fix**: The exact solution that worked, including code/config snippets if relevant.
```

## Rules

- Be specific — vague entries are useless. Include option names, file paths, plugin names, error messages.
- If multiple things failed before the fix, list each failed attempt under **What failed**.
- If the fix involved writing a special character or binary content, note the exact method (e.g. "write via Python, not Edit tool").
- Group related lessons under the same top-level `##` section heading (e.g. `## Neovim`, `## Yazi`). Add a new heading if the topic doesn't fit any existing one.
- Keep entries concise but complete — a future Claude reading this should be able to avoid the exact same mistake.
