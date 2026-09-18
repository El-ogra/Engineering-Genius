---
name: module-execution
description: "Use this skill ONLY for EXECUTION PREPARATION — when user says 'استخدم تقنية لوب إنجنيرنغ لـ', 'use loop-engineering to execute', 'نفّذ الخطة', 'execute plan', 'ابدأ التنفيذ', or any request to prepare execution of an ALREADY-APPROVED plan file. This skill generates a memory file and drafts an execution prompt — it does NOT execute any slices itself."
license: MIT
compatibility: opencode
---

# Module Execution Skill

Prepares an already-approved implementation plan for slice-by-slice execution. This skill does **two things only**: (1) generates a memory file, and (2) drafts an execution prompt. It does **NOT** execute any slices, write any application code, or run any build/test commands.

## When to Activate

This skill activates when the user's message matches:
- "استخدم تقنية لوب إنجنيرنغ لـ [filename].md" / "use loop-engineering to execute [filename].md"
- "نفّذ الخطة [filename].md" / "execute plan [filename].md"
- "ابدأ التنفيذ [filename].md" / "start execution [filename].md"
- "لوب إنجنيرنغ [filename].md" / "loop engineering [filename].md"

Do NOT use for: creating plans (use `module-planning` skill instead), design-only discussions, or actually executing slices.

## Input Required

1. **Plan File Path** — the approved `.md` plan file (e.g., `Docs/OpenCode/M-12.md`)
2. **Starting Slice** (optional) — which slice to start from (default: Slice 1)

## Workflow — 2-Step Process

### Step 1: Generate the Memory File

Read the referenced plan file and create `Docs/OpenCode/M-XX-memory.md` (where XX = the module number).

The memory file must contain:

**Header & Metadata (from memory-file-template.md B1):**
- Module name, module number, source plan path, date created, total slices, current slice (0), current branch, author
- If slices are explicit in the plan: omit the "Inferred Slices" header lines
- If slices were inferred: prepend the two inference-comment header lines

**Module Summary & Validation Gates (B2):**
- 1-3 sentence summary of what the module does
- Global validation gates: G0 (pre-execution: build zero errors + zero warnings, tests pass 100%), G1 (post-execution: same plus slice-specific gate)
- Per-slice validation gates table

**Slice Index (B3):**
- Table with slice number, title, status, validation gate
- All statuses start as `[ ] Not started`

**Per-Slice 10-Stage Checklists (B4):**
- One block per slice, each containing the 10 stages as empty checkboxes
- Each checkbox starts as `- [ ]`
- The 10 stages MUST appear in order and must not be merged
- Stage 1 and Stage 6 must state `zero errors + zero warnings` (not "warnings are OK")

**Current Status & Execution Log (B5):**
- Overall status: `0/N slices done`
- Per-slice status lines (all `[ ] Not started`)
- Empty execution log table
- Stop report section (empty, ready to be appended if triggered)

**Stop/Continue Rule — Explicit in the memory file:**
After a slice completes, verify success via:
(a) the full solution builds with zero errors and zero warnings
(b) all existing tests pass
(c) that slice's specific validation gate(s) pass

Only if all three hold does execution proceed immediately to the next slice; otherwise it stops and reports.

### Step 2: Draft the Execution Prompt

Using the existing `execution-prompt.md` template, produce the exact prompt text the owner will separately send to the executing agent to actually run the loop across all slices, based on the memory file just created.

Present this drafted prompt back to the owner as output text. Do NOT begin executing any slice. This skill invocation ends after producing the memory file and the drafted prompt.

## Output

### Artifact 1: Memory File
`Docs/OpenCode/M-XX-memory.md` — complete, ready for the executing agent to use

### Artifact 2: Drafted Execution Prompt
Presented as output text — the owner decides when and to whom to send it

## Anti-Patterns

1. Never execute any slices — this skill only prepares
2. Never write application source code
3. Never run `dotnet build`, `dotnet test`, or any build/test commands
4. Never run `git add`, `git commit`, or `git push`
5. Never create the memory file without the explicit stop/continue rule
6. Never skip any of the 5 sections (B1-B5) in the memory file
7. Never mark any checkbox as `[x]` at creation time — all start as `[ ]`

## Reference Files

- `references/10-stage-loop.md` — Detailed per-stage procedure (for the executing agent, not this skill)
- `references/stop-conditions.md` — When to halt (embedded in memory file)
- `references/anti-patterns.md` — What to avoid
- `references/memory-file-template.md` — Memory file structure (B1-B5)
- `references/execution-prompt.md` — Execution prompt template (used to draft the prompt)
