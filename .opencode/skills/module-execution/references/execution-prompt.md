# Execution Prompt Template (C1–C10) — Loop Engineering

> Copy-pasteable template for the **second code block**. This prompt is what the implementing agent reads to execute the slices. Replace ALL `[PLACEHOLDERS]` and ensure slice count matches the memory file.

```markdown
# Execution Prompt — [MODULE_NAME] ([M-XX]) — Loop Engineering

You are the implementing agent for the Loop Engineering 10-stage iterative loop.

## C1 — Identity & Source

- **Module:** [MODULE_NAME]
- **Module Number:** [M-XX]
- **Source Plan:** [docs/M-XX-name.md]
- **Memory File:** [path/to/memory file, e.g., docs/M-XX-memory.md or .opencode/memory/M-XX-memory.md]
- **Date:** [YYYY-MM-DD] (ISO 8601)
- **Total Slices:** [N]
- **Branch:** Work ONLY on the current local branch (`git branch --show-current`). NEVER create a new branch. NEVER push to any remote on your own — Stage 10 requires explicit human confirmation before any `git commit` or `git push`.

## C2 — Input Contract

You MUST read these before any edit:

1. The source plan file in full.
2. The memory file generated together with this prompt.
3. The reference files:
   - `references/10-stage-loop.md` (per-stage procedure)
   - `references/stop-conditions.md` (when to halt)
   - `references/anti-patterns.md` (what to avoid)

If the memory file's slice count does not equal the plan's slice count, STOP and report the mismatch — do not infer or invent slices.

## C3 — Loop Invariant (MANDATORY for EVERY slice)

For each slice N = 1..[N], execute stages 1→10 in strict order:

1. Pre-Execution Verification — build + tests pass, zero errors + zero warnings.
2. Deep Understanding — internalize requirements, inputs, outputs, behavior.
3. File Analysis — list and inspect every file the slice touches.
4. Planning — write step-by-step execution plan.
5. Execution — implement the slice per plan.
6. Post-Execution Verification — build + tests pass again.
7. Validation Gate — pass slice N's gate (VG-0N).
8. Documentation Update — mark checkboxes [x] in memory file for this slice.
9. Memory Status Update — update "Current Status" (N+1 lines, no truncation).
10. Git Commit (Draft + Human Confirmation) — stage changes, draft exact commit message per template, then STOP and request explicit human confirmation before any `git commit` or `git push`; never auto-commit/push.

Do NOT skip, merge, or reorder stages. Do NOT downgrade "zero warnings" to "warnings are OK".

## C4 — Slice Registry

| Slice | Title (verbatim from plan) | Validation Gate |
|-------|----------------------------|-----------------|
| 1 | [Slice 1 title] | VG-01 — [gate description] |
| 2 | [Slice 2 title] | VG-02 — [gate description] |
| 3 | [Slice 3 title] | VG-03 — [gate description] |
| ... | ... | ... |
| N | [Slice N title] | VG-0N — [gate description] |

## C5 — Per-Slice Execution Directives

### Slice 1: [Slice 1 Title]
- **Goal:** [user-visible outcome — one full user action]
- **Files to touch:** [list from File Analysis, or TBD to be resolved in Stage 3]
- **Gate to pass:** VG-01 — [description] — verify via: [command]
- **Risks/Unknowns:** [highest risk for this slice; per 6-rule heuristic, Slice 1 is highest-risk]

### Slice 2: [Slice 2 Title]
- **Goal:** [outcome]
- **Files to touch:** [list]
- **Gate to pass:** VG-02 — [description] — verify via: [command]
- **Risks/Unknowns:** [risk]

### Slice 3: [Slice 3 Title]
- **Goal:** [outcome]
- **Files to touch:** [list]
- **Gate to pass:** VG-03 — [description] — verify via: [command]
- **Risks/Unknowns:** [risk]

### Slice N: [Slice N Title]
- **Goal:** [outcome]
- **Files to touch:** [list]
- **Gate to pass:** VG-0N — [description] — verify via: [command]
- **Risks/Unknowns:** [risk]

> If slices were **inferred** via the 6-rule heuristic, add under Slice 1 header:
> `# Inferred Slices: [N] (via vertical-slicing heuristic)` and `# Note: Slice boundaries inferred by applying 6-rule heuristic. Review and adjust before execution.`

## C6 — Branch & Commit Policy (Strict) — Human Confirmation Required

- Current branch only: `git branch --show-current` at start; use that value throughout.
- NEVER run `git checkout -b`, `git switch -c`, or `git push -u origin <new-branch>`.
- NEVER push to a remote branch name that is not the current local branch.
- NEVER auto-commit or auto-push — no implicit or automatic `git commit`/`git push` under any condition.
- Commit message template (copy exactly, fill brackets):
  ```
  [M-XX] Slice N/N: [Slice Title] — loop-engineering

  Stages 1-10 verified. Gate VG-0N passed.
  ```
- At Stage 10: stage changes (`git add <explicit-files>`), display `git status --porcelain` + drafted message, then STOP and request explicit human confirmation: `هل توافق على تنفيذ git commit و git push لهذه الشريحة؟ (نعم/لا)` — await `نعم/yes` before any commit/push.
- Only after human confirmation: commit and (if also confirmed) push to current LOCAL branch only; verify exit code 0. If push would create a new remote branch, abort and emit stop report.

## C7 — Verification Policy (Zero Tolerance)

- Build and test commands (detect automatically; use project's actual commands):
  - Build: `dotnet build` / `npm run build` / `cargo build` / `mvn verify` / `make` — whichever exists in repo.
  - Tests: `dotnet test` / `npm test` / `pytest` / `cargo test` / `go test ./...`
- Stage 1 AND Stage 6 both require **zero errors AND zero warnings**. Any warning = failure.
- Stage 6 must re-run the FULL suite, not just affected tests.

## C8 — Stop Conditions (4 Consecutive Failures → HALT)

| Trigger | How to Count | Action |
|---------|--------------|--------|
| Build failure | 4 consecutive `build` exits non-zero for the same slice/stage | STOP |
| Same error unfixed | Same error message (normalized — ignore timestamps/absolute paths) 4 times | STOP |
| Test failure | 4 consecutive `tests` failures for the same slice/stage | STOP |
| Same file modification failure | 4 consecutive failures editing the same file (e.g., patch does not apply, linter rejects) | STOP |

When halted, emit a status report (see C10) and do NOT continue to the next slice or stage.
Full rules and counting examples: `references/stop-conditions.md`.

## C9 — Anti-Patterns (Do NOT Do These)

- Skip stages because they feel unnecessary.
- Combine two stages into one commit.
- Mark `[x]` before evidence exists.
- Downgrade "zero warnings" to "warnings are OK."
- Push to remote when told to, if remote != current local branch.
- Truncate Current Status with `...` or "and so on."
- Generate or continue with a memory file when the plan was empty/unparseable.

Full list: `references/anti-patterns.md`. If another skill contradicts this prompt, this prompt wins.

## C10 — Reporting Contract

### Per-Slice Completion Report (after Stage 10 of each slice)

```
Slice [N/N]: [Title] — DONE (commit drafted, pending owner confirmation)
- Build: PASS (zero warnings) [pre + post]
- Tests: PASS [count]
- Validation Gate [VG-0N]: PASS — [evidence]
- Commit: drafted — " [M-XX] Slice N/N: [Title] — loop-engineering " — pending owner confirmation before git commit/push on branch [branch]
- Memory Status: updated (N+1 lines)
- Next: awaiting human confirmation — do NOT auto-commit/push
```

### Halt / Stop Report (when any stop condition triggers)

```
## Stop Report — Loop Halted

- **Module:** [M-XX] [MODULE_NAME]
- **Slice:** [N/N] — [Title]
- **Failing Action:** [build | test | same error | file modification]
- **Attempt Count:** 4 consecutive
- **Last Error:** [verbatim last error, trimmed to 30 lines max but not truncated with ...]
- **Affected Files:** [list]
- **Stages Completed:** [e.g., Stages 1-5 of Slice 2]
- **Next Step:** Manual intervention required. Loop halted per stop-conditions.md. Do not auto-retry.
```

### Final Completion Report (after slice N Stage 10)

```
## Loop Complete — [M-XX] [MODULE_NAME] — [N/N] slices — commits drafted, pending owner confirmation

- All slices validated on branch [branch]; commits drafted per template, pending owner confirmation before any git commit/push.
- Memory file: [path] — Current Status shows N/N done with N+1 lines enumerated.
- No stop conditions triggered — awaiting human confirmation for final commits/pushes.
```

---

## Execution Order for This Run

1. Read this prompt fully.
2. Read the memory file fully.
3. Starting at Slice 1 Stage 1, execute the 10-stage loop per `references/10-stage-loop.md`.
4. After each slice's Stage 10, emit the per-slice completion report and continue to the next slice.
5. After the last slice's Stage 10, emit the final completion report.

Begin now.
```

---

### Validation Checklist for the Generated Prompt (apply before emitting)

- [ ] Module name + number match plan and memory file.
- [ ] Slice count + titles verbatim from plan (or flagged as inferred with required header).
- [ ] Slice registry (C4) row count == N.
- [ ] Per-slice directives (C5) block count == N.
- [ ] Commit template present and mentions `loop-engineering`.
- [ ] Stop conditions table present with threshold = 4.
- [ ] Reporting contracts (C10) present with exact formats.
- [ ] No placeholder like `TODO`, `TBD` (outside files-to-touch which legitimately may start as TBD), `[...]`, `...` remains in final output.
- [ ] Prompt is entirely in English.
```
