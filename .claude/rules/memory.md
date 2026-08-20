# Memory

**On session start:** the committed `.claude/memory/MEMORY.md` (invariants, decision log,
session history) is injected into context by the `load-memory` SessionStart hook. If it is NOT
already present in context (hook disabled, untrusted, or absent), read it now before responding
to anything.

Then confirm:
"📖 MEMORY loaded — [I] invariants, [D] decisions, [S] sessions. Resuming from: [last session title]."

- Treat `## Invariants & Gotchas` as binding — established facts and traps, not suggestions.
  If one bears on the current task, say so before doing anything that contradicts it.
- **Domain files are NOT injected by the hook.** Before editing anything under `sketchybar/`,
  read `.claude/memory/MEMORY-sketchybar.md` — the SketchyBar invariants were split out of
  `MEMORY.md` on 2026-08-10 and are binding in exactly the same way. New SketchyBar invariants
  go in that file, not the active one; decisions and session history stay in `MEMORY.md`.
- If a logged decision is relevant to the current task, acknowledge it before proceeding.
- Never contradict a logged decision without flagging it:
  > "⚠️ This conflicts with a prior decision: [quote]. Proceeding anyway because: [reason].
  >  Should I update the log?"

For the full protocol — logging format, session-summary block, archiving, quality standards
— follow the `memory-log` skill. Invoke it when recording a decision or wrapping up.
