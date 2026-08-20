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
