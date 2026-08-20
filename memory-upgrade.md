# Memory Protocol Upgrade — Portable Runbook

Single canonical spec for upgrading the hand-rolled memory protocol across all my repos.
Reference it by absolute path; **do not copy it into repos** (copying is what caused the
drift this fixes). Open a Claude Code session in the target repo and use the kickoff prompt
at the bottom.

Claude runs four **gated** phases — DISCOVER → PLAN → APPLY → VERIFY — stopping for approval
between each. Repos differ (CC version, current protocol form, MEMORY.md bloat, whether
`.claude/` is committed, submodules). This runbook describes a **target end state** and
converges each repo to it **idempotently** — it is not a blind diff. Re-running it on an
already-migrated repo is a no-op.

---

## 1. Decisions baked in (do NOT re-decide per repo)

The whole point of standardizing is deciding once. Every repo converges to the same choices:

1. **Keep hand-rolled, committed memory as the single source of truth.** The committed
   `.claude/memory/MEMORY.md` (append-only Decisions Log + capped Session History) is canonical.
2. **Native Auto Memory OFF at project level** — `autoMemoryEnabled: false` in a committed
   `.claude/settings.json`. Native Auto Memory is machine-local and not shared via git;
   running it alongside the committed file creates two diverging systems.
3. **SessionStart hook INCLUDED at project level.** It injects `.claude/memory/MEMORY.md` into
   context on `startup|resume|clear|compact` — so memory is deterministic at start **and
   survives compaction** (`.claude/memory/MEMORY.md` is not a `CLAUDE.md` file and is otherwise
   dropped by `/compact`). The `📖` confirmation line is emitted by Claude per the rule.
4. **Session History cap = 4** (down from 6), **one-line bullets** only. Detail lives in git
   history, not the file.
5. **File targets:** active memory file **≤120 lines**. The binding constraint is the SessionStart
   hook's **stdout injection threshold**, not the native read limit (the original justification
   here was wrong). The hook `cat`s the file to stdout; past the threshold the harness stops
   injecting that stdout and substitutes a short preview pointing at a temp file. **Memory then
   silently stops loading** — the session still reports the hook as `success`, so nothing
   announces the failure and the `📖` confirmation gets emitted against a preview.

   **Two sources disagree on where that threshold is, and the conflict is unresolved.** The hooks
   reference documents a hard cap of **10,000 characters** on all hook output: *"Output that
   exceeds this limit is saved to a file and replaced with a preview and file path."* But a field
   measurement on whitelabelslot 2026-08-06 found hook stdout of **24,358 B injecting fine across
   three sessions, while 28,314 B and 29,109 B did not** — 2.4× the documented cap. The
   measurement may predate a tightening, or have been misread. Until someone bisects it, **budget
   hook stdout at ≤9,000 characters**, which is safe under both readings. The hook's own wrapper
   is 108 B, so budget the file itself at **≤8,900 characters**. Treat this as a hard functional
   limit, not a style target.

   **Verify the real number by running the hook, not by estimating:**
   `bash .claude/hooks/load-memory.sh | wc -m`. **Raising the cap is not an available lever** —
   the threshold is the harness's, not ours.
6. **Decisions Log is append-only in substance, but not unbounded in the hot path.** Never
   rewrite what was decided or why. When an entry is **superseded**, or records a one-off change
   that has **fully shipped**, relocate it **verbatim** to `MEMORY_archive.md` in the same edit
   that supersedes it. Archiving is routine hygiene, not a rescue operation.
7. **Durable facts live in `## Invariants & Gotchas`, not in the Decisions Log.** A decision has
   alternatives and can be superseded; an invariant is just permanently true ("pnpm 10+ ignores
   `package.json` `pnpm.overrides`"). Invariants are one line each, never archived, and stay
   cheap because they don't accumulate the way decisions do. Keeping them inside verbose
   decision entries is what drives files over target.
8. **Decisions Log entry budget ≈800 characters** (~8 wrapped lines) across DECISION/REASON/
   REJECTED. Changelog detail belongs in the ticket, PR and git history — where it is actually
   discoverable. The log carries reasoning, not a record of what shipped.
9. **Submodule memory is governed by the same protocol text but NEVER edited from the outer
   repo** (submodule commits only) — out of scope for this migration run.

> **Why 6–8 exist.** A permanent, append-only log inside a file injected at every session start
> will always eventually blow its budget; the only question is whether that surfaces as routine
> hygiene or as an emergency remediation. Observed in the field 2026-07-28: a log reached
> 15.4 KB of a 21.9 KB file, with the highest-value content (a resolver gotcha, a wrong-remote
> warning) buried inside 500-character entries about PRs merged weeks earlier.

---

## 2. Target end state (files + reference content)

Apply with "ensure" semantics — bring each file to this state; skip if already conformant.

**Submodules are optional.** Two files — the rule (§2c) and the skill (§2d) — each come in two
complete variants: **-A (no submodules)** and **-B (submodule-aware)**, differing by a few
lines. `git submodule status` in DISCOVER decides which. In APPLY, reproduce the chosen
variant **character-for-character** — never merge the two, splice lines, reword, or reflow.
Every other file (§2a, §2b, §2e, §2f) is single-variant. Net: a repo with no submodules ends
up with zero submodule references anywhere; a repo with one gets an identical submodule-aware set.

### 2a. `.claude/settings.json` (committed) — MERGE, do not clobber

If the file exists, merge these keys into it (preserve any existing keys/hooks). If a
`SessionStart` hook already exists, add ours as an additional entry rather than replacing.

```json
{
  "autoMemoryEnabled": false,
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          { "type": "command", "command": "\"$CLAUDE_PROJECT_DIR/.claude/hooks/load-memory.sh\"", "timeout": 10 }
        ]
      }
    ]
  }
}
```

If the installed CC version rejects the `|` alternation in `matcher`, split into one entry
per source, or omit `matcher` (fires on all SessionStart sources).

### 2b. `.claude/hooks/load-memory.sh` (committed, `chmod +x`)

```bash
#!/usr/bin/env bash
# SessionStart hook — inject the committed .claude/memory/MEMORY.md into context so it is
# present at startup/resume/clear AND survives compaction (.claude/memory/MEMORY.md is not a
# CLAUDE.md file, so it is not auto-re-injected after /compact). The 📖 confirmation is emitted
# by Claude per .claude/rules/memory.md, using the content this hook provides.
set -euo pipefail
mem="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/memory/MEMORY.md"
[ -f "$mem" ] || exit 0
printf '=== BEGIN committed MEMORY.md (project decision log + session history) ===\n'
cat "$mem"
printf '\n=== END committed MEMORY.md ===\n'
```

### 2c. `.claude/rules/memory.md` (committed) — always-on trigger

Session-start behavior lives here (always-on). The write procedure lives in the skill. Copy
ONE variant below verbatim (see §2's A/B rule); they differ by a single bullet.

#### 2c-A — no submodules

```text
# Memory

**On session start:** the committed `.claude/memory/MEMORY.md` (invariants, decision log,
session history) is injected into context by the `load-memory` SessionStart hook. If it is NOT
already present in context (hook disabled, untrusted, or absent), read it now before responding
to anything.

Then confirm:
"📖 MEMORY loaded — [I] invariants, [D] decisions, [S] sessions. Resuming from: [last session title]."

- Treat `## Invariants & Gotchas` as binding — established facts and traps, not suggestions.
  If one bears on the current task, say so before doing anything that contradicts it.
- If a logged decision is relevant to the current task, acknowledge it before proceeding.
- Never contradict a logged decision without flagging it:
  > "⚠️ This conflicts with a prior decision: [quote]. Proceeding anyway because: [reason].
  >  Should I update the log?"

For the full protocol — logging format, session-summary block, archiving, quality standards
— follow the `memory-log` skill. Invoke it when recording a decision or wrapping up.
```

#### 2c-B — submodule-aware (repo vendors a submodule with its own `MEMORY.md`)

```text
# Memory

**On session start:** the committed `.claude/memory/MEMORY.md` (invariants, decision log,
session history) is injected into context by the `load-memory` SessionStart hook. If it is NOT
already present in context (hook disabled, untrusted, or absent), read it now before responding
to anything.

Then confirm:
"📖 MEMORY loaded — [I] invariants, [D] decisions, [S] sessions. Resuming from: [last session title]."

- Treat `## Invariants & Gotchas` as binding — established facts and traps, not suggestions.
  If one bears on the current task, say so before doing anything that contradicts it.
- If a logged decision is relevant to the current task, acknowledge it before proceeding.
- Never contradict a logged decision without flagging it:
  > "⚠️ This conflicts with a prior decision: [quote]. Proceeding anyway because: [reason].
  >  Should I update the log?"
- When working on submodule/framework code, also load that submodule's `MEMORY.md`.

For the full protocol — logging format, session-summary block, archiving, quality standards
— follow the `memory-log` skill. Invoke it when recording a decision or wrapping up.
```

### 2d. `.claude/skills/memory-log/SKILL.md` (committed) — on-demand procedure

Removes the vestigial "Setup" block, de-duplicates the session-start behavior (now owned by
the rule), adds the native-memory note, and tightens File Health & Archiving. Copy ONE
variant below verbatim (see §2's A/B rule).

#### 2d-A — no submodules

````markdown
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
````

#### 2d-B — submodule-aware (repo vendors a submodule with its own `MEMORY.md`)

````markdown
---
name: memory-log
description: Project decision-log and session-history protocol. Use when recording a significant decision, starting/wrapping a work session, or maintaining the .claude/memory/MEMORY.md or a submodule's MEMORY.md. Covers logging format, session-summary blocks, archiving, and entry-quality standards.
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
Applies to `.claude/memory/MEMORY.md` and any submodule `MEMORY.md` (each manages its own archive).

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
- **Submodule memory is edited only via submodule commits** — never from the outer repo.

## Entry Quality Standards
- Be specific, not vague. "Used X over Y because Y added boilerplate for no benefit at this
  scope" > "Chose a library."
- Log the rejection — what you didn't do and why prevents relitigating.
- One decision per entry, ≈800 characters max. Reasoning in, changelog out.
- Decisions Log is append-only **in substance** — supersede, don't rewrite. Superseding means
  moving the old entry to the archive, not leaving both in the active log.
- If you catch yourself preserving a fact while trimming an entry, it is an invariant — promote
  it to `## Invariants & Gotchas` instead.
- Write game/project-level decisions to `.claude/memory/MEMORY.md`; framework/submodule-level → that submodule's `MEMORY.md`.
````

### 2e. `.claude/memory/MEMORY.md` (data) — converge & remediate

- **Location:** the canonical file is `.claude/memory/MEMORY.md`. If a legacy root `MEMORY.md`
  (and `MEMORY_archive.md`) exists, `git mv` it into `.claude/memory/` to preserve history
  before remediating.
- Ensure structure: `# <Project> Memory` → `## Invariants & Gotchas` (one-liners) →
  `## Decisions Log` (append-only in substance) → `## Session History` (most recent first).
- **Decisions Log: never rewrite what was decided or why.** Condensing an over-budget entry is
  permitted — and expected — provided every load-bearing fact survives; relocating a superseded
  or fully-shipped entry is permitted provided it moves **verbatim** to the archive. What is
  forbidden is changing the substance of a past decision, or silently dropping one.
- Seed `## Invariants & Gotchas` during remediation: as you condense entries, promote the facts
  you find yourself fighting to keep (resolver quirks, wrong-remote traps, tool
  incompatibilities) into one-liners there.
- If over target (>120 lines / >10 KB) or >4 session blocks: move the oldest session block(s)
  to `.claude/memory/MEMORY_archive.md`, and collapse retained blocks to one-line bullets. This
  is data-shaped, not a fixed edit — archive until under target.

### 2f. `.claude/memory/MEMORY_archive.md` (committed) — created on first overflow; never auto-read.

Holds two kinds of overflow, under separate headings: Session History blocks (oldest first), and
a `## Decisions Log — Archived` section for superseded or fully-shipped decisions, stored
verbatim with a note of when and why each was relocated.

---

## 3. Phase 1 — DISCOVER (read-only; change nothing)

Run and report as a table. Do not edit anything in this phase.

```bash
claude --version                                   # need SessionStart hooks + project autoMemoryEnabled (>= 2.1.x)
ls -la .claude/rules .claude/skills 2>/dev/null    # current protocol form?
grep -rn -i 'memory' CLAUDE.md .claude/rules 2>/dev/null   # skill? old @-import? tiny trigger? none?
git ls-files .claude MEMORY.md .claude/memory 2>/dev/null   # what's committed? (root MEMORY.md = legacy)
git submodule status --recursive 2>/dev/null || echo 'no submodules'   # submodule MEMORY.md files live here, if any
git check-ignore -v .claude/settings.json .claude/rules/memory.md 2>/dev/null || echo ".claude not ignored"
wc -l .claude/memory/MEMORY.md MEMORY.md 2>/dev/null; du -h .claude/memory/MEMORY.md MEMORY.md 2>/dev/null   # health vs target (new path + legacy root)
grep -i automemory ~/.claude/settings.json .claude/settings.json .claude/settings.local.json 2>/dev/null
echo "env CLAUDE_CODE_DISABLE_AUTO_MEMORY=${CLAUDE_CODE_DISABLE_AUTO_MEMORY:-unset}"
cat .gitmodules 2>/dev/null                        # submodules present?
cat .claude/settings.json 2>/dev/null              # existing keys/hooks to MERGE with
```

Report: current protocol form (skill / `@`-import / tiny-trigger / none / already-migrated) ·
CC version OK? · is `.claude/` committed or gitignored? · MEMORY.md size vs target · native
Auto Memory on/off and where set · submodules present · existing `settings.json` keys.

## 4. Phase 2 — PLAN

Produce a repo-specific diff plan to reach §2, and **explicitly flag any delta** from the
reference, e.g.:
- `.claude/` is gitignored here → committed settings/hook/rule/skill won't be team-shared. **Stop and ask.**
- Still on the old `@`-import form (`.claude/rules/memory-protocol.md` imported in CLAUDE.md)
  → migrate: move the procedure into the `memory-log` skill, replace the import with the tiny rule.
- No `.claude/memory/MEMORY.md` yet → create it (empty Decisions Log + Session History scaffold); skip remediation.
- Legacy `MEMORY.md`/`MEMORY_archive.md` at repo root → `git mv` into `.claude/memory/` (preserve history) and point the hook at the new path.
- `MEMORY.md` already conforms → skip 2e.
- CC version too old for hooks / project `autoMemoryEnabled` → flag; fall back to prompt-only load and note it.
- Global `CLAUDE_CODE_DISABLE_AUTO_MEMORY` set, or native Auto Memory disabled in
  `~/.claude/settings.json` → note it: a machine-global override already exists, but this
  runbook only writes the project-level `autoMemoryEnabled: false` and does **not** change
  global/user settings.

## 5. Phase 3 — APPLY (on approval; surgical + idempotent)

- **Merge**, don't clobber, `.claude/settings.json`. `chmod +x` the hook script.
- Only touch files in §2. Reproduce the §2c/§2d reference blocks **verbatim** — do not reword,
  reflow, or "improve" the protocol text. The "match the repo's existing style" guidance
  applies only to incidental code edits, never to the protocol content.
- **Submodules:** `git submodule status` decides the variant. Copy the **-A** blocks (§2c-A,
  §2d-A) for a repo with no submodules, or the **-B** blocks (§2c-B, §2d-B) for one that
  vendors a submodule with its own `MEMORY.md`. Copy one whole — never assemble one from the
  other. Never touch the submodule's files from the outer repo.
- Preserve every Decisions Log fact. Reformatting into the current entry shape is fine, and a
  superseded/shipped entry may be relocated verbatim to the archive — but never drop a reason
  or a rejected alternative to hit the size target.
- Honor the repo's own `CLAUDE.md` / workflow rules (e.g., ask before compiling). No TS
  changes here, so no build is required unless the repo says otherwise.

## 6. Phase 4 — VERIFY

- `/context` → the rule + skill appear under Memory files.
- `/memory` → Auto Memory shows OFF.
- Start a fresh session → accept the one-time workspace-trust prompt → the hook injects
  `.claude/memory/MEMORY.md` and the `📖 MEMORY loaded — …` line appears.
- `git status` shows exactly the expected files (`.claude/settings.json`, hook, rule, skill,
  `.claude/memory/MEMORY.md`, maybe `.claude/memory/MEMORY_archive.md`) and nothing under any
  submodule.
- **Append a Decisions Log entry** recording the upgrade (date · what changed · reason ·
  rejected alternatives) — dogfood the protocol.

---

## 7. Boundaries & gotchas

- **Never touch a submodule.** Framework/submodule memory changes are submodule commits, out
  of scope for this run.
- **Merge, don't overwrite** an existing `.claude/settings.json`.
- **Respect gitignore.** If a repo gitignores `.claude/`, the committed artifacts won't be
  team-shared — flag it and ask; don't proceed silently.
- **Version gate.** Requires a CC version with `SessionStart` hooks + project-level
  `autoMemoryEnabled`. If older, stop or fall back to prompt-only and say so.
- **Trust prompt.** The project hook triggers a one-time workspace-trust prompt per machine —
  expected, not a failure.
- **autoMemory scoping.** `autoMemoryEnabled: false` in the game project won't cover sessions
  launched with CWD *inside* a submodule (CC treats it as a separate project). Minor.

---

## 8. Kickoff prompt (paste into a session in the target repo)

> Read `~/dotfiles/memory-upgrade.md`. It's a standardized upgrade for my memory protocol,
> which exists in this repo in a possibly-drifted state. Do **not** assume this repo matches
> any other — discover before you change anything.
>
> Work in gated phases, stopping for my approval between each:
> 1. **DISCOVER** — verify this repo against the runbook's Phase 1 checklist and report as a
>    table. Change nothing.
> 2. **PLAN** — a repo-specific diff plan to reach the runbook's target end-state; call out
>    every delta from the reference and anything needing my decision.
> 3. **APPLY** — on my go, make surgical edits (copy the §2c/§2d reference blocks verbatim),
>    honor this repo's CLAUDE.md/workflow rules
>    (ask before compiling), merge into any existing `.claude/settings.json` rather than
>    overwrite, log a Decisions Log entry, and give me the Phase 4 verification checklist.
>    Never touch a submodule.
