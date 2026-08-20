---
name: memory-log
description: Project decision-log and session-history protocol. Use when recording a significant decision, starting/wrapping a work session, or maintaining the .claude/memory/MEMORY.md. Covers logging format, session-summary blocks, archiving, and entry-quality standards.
---

# Memory Protocol

Session-start behavior (loading MEMORY.md, the 📖 confirmation, acknowledging/flagging logged
decisions) lives in the always-on `.claude/rules/memory.md` trigger. This skill is the
on-demand procedure for WRITING to the log and keeping it healthy.

## Relationship to native Auto Memory
Native Claude Code Auto Memory is intentionally DISABLED at project level
(`autoMemoryEnabled: false` in `.claude/settings.json`). It is machine-local and not shared
via git; this project's committed `MEMORY.md` is the single, team-shared source of truth. Do
not re-enable it here — running both creates two parallel, diverging memory systems.

## On any significant decision
Append to the Decisions Log immediately:
```
[YYYY-MM-DD] DECISION: <what was decided>
              REASON: <why>
              REJECTED: <alternatives considered and why they were ruled out>
```
"Significant" = architectural choices, naming conventions, dependency additions, structural
refactors, and any choice where a different path was plausible.

**Budget ≈800 characters per entry** (~8 wrapped lines) across all three fields. If it runs
longer you are writing a changelog: cut the shipped detail — PR numbers, file counts, version
lists, diff stats — and keep the reasoning. The ticket, PR and git history hold the rest, and
hold it better.

**Decision or invariant?** If there were no real alternatives and it cannot be superseded — it
is simply true about this codebase ("pnpm 10+ silently ignores `package.json` `pnpm.overrides`",
"the real remote is X, not Y") — it belongs in `## Invariants & Gotchas` as a one-liner, NOT in
the Decisions Log. These are the facts future sessions most need and most often lose, because
they get buried inside long entries about work that already shipped.

## Invariants & Gotchas
A `## Invariants & Gotchas` section sits at the TOP of the memory file, above the Decisions Log.
It holds the facts a future session would waste real time rediscovering: resolver quirks,
package-manager constraints, wrong-remote traps, tool incompatibilities, "looks like a one-liner
but isn't" landmines.

- One line each. No REASON/REJECTED scaffolding — just the fact, and the trap it avoids.
- Never archived and never superseded: correct it in place if it changes, delete it if it stops
  being true.
- Whenever you condense or archive a decision, promote any fact you find yourself fighting to
  preserve into this section. That instinct is the signal it was never really a decision.

## On session end ("wrapping up" / "let's stop here")
Prepend a session summary to the TOP of Session History. Keep every bullet to ONE line —
narrative detail belongs in git history, not this file:
```
## Session — [YYYY-MM-DD]
### Worked On
-
### Completed
-
### In Progress (with next step)
-
### Decisions Made
- (reference Decisions Log entries by date)
### Next Session Priorities
1.
```

## File Health & Archiving
Applies to `.claude/memory/MEMORY.md`.

- **Decisions Log — substance kept forever, bulk is not.** Never rewrite what was decided or
  why. But when you supersede an entry, or an entry records a one-off change that has fully
  shipped, relocate it **verbatim** to `MEMORY_archive.md` in the SAME edit — under a
  `## Decisions Log — Archived` heading, noting when and why it moved. Superseded text left in
  the active log is pure cost: read every session, never actionable.
- **Invariants & Gotchas — never archived, but they do NOT stay cheap.** The "one-liners are
  self-limiting" premise failed in practice: ~75 invariants averaging ~330 B are structurally
  ~23 KB — 2.6× the entire budget on their own. When invariants alone approach the ceiling, the
  fix is a **domain split** — move a closed programme's invariants to
  `.claude/memory/MEMORY-<domain>.md` and leave a pointer in the active file, with a matching
  load trigger in `.claude/rules/memory.md`. Never delete a proven invariant to make a number fit.
- **Session History — cap at 4.** On every session-end write, if there are more than 4 blocks
  OR the file is over target, move the oldest block(s) to `.claude/memory/MEMORY_archive.md`
  (create if absent) before appending the new one. The archive is never read automatically.
- **Target ≤120 lines. HARD ceiling ≤8,900 characters per active file — a functional limit, not
  a style target.** The hooks reference caps hook output at 10,000 characters; a 2026-08-06 field
  measurement instead saw 24,358 B inject cleanly. The conflict is unresolved, so budget under the
  stricter number. Past the threshold (the file itself + 108 B of wrapper) the harness stops
  injecting and substitutes a preview, so **memory silently stops loading while the hook still
  reports `success`**. Raising the cap is not a lever — the threshold is the harness's. Verify
  with `bash .claude/hooks/load-memory.sh | wc -m` on every session-end write. If a file drifts
  over: terser entries, then archiving, then a **domain split**. Check the ≈800-char entry budget
  first — an over-target file is usually a handful of bloated entries, not too many of them.

## Entry Quality Standards
- Be specific, not vague. "Used X over Y because Y added boilerplate for no benefit at this
  scope" > "Chose a library."
- Log the rejection — what you didn't do and why prevents relitigating.
- One decision per entry, ≈800 characters max. Reasoning in, changelog out.
- Decisions Log is append-only **in substance** — supersede, don't rewrite. Superseding means
  moving the old entry to the archive, not leaving both in the active log.
- If you catch yourself preserving a fact while trimming an entry, it is an invariant — promote
  it to `## Invariants & Gotchas` instead.
- Write everything project-level to `.claude/memory/MEMORY.md`.
