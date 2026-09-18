# Memory File Template (B1–B5) — Loop Engineering

> Copy-pasteable template. Replace ALL `[PLACEHOLDERS]` before use. Keep English only. Date must be `YYYY-MM-DD`.
> If slices were inferred via the 6-rule heuristic, prepend the two header lines shown in B1.

---

## B1 — Header & Metadata

```markdown
# Inferred Slices: [N] (via vertical-slicing heuristic)
# Note: Slice boundaries inferred by applying 6-rule heuristic. Review and adjust before execution.

# Loop Engineering — Memory File

- **Module:** [MODULE_NAME] — e.g., User Authentication
- **Module Number:** [M-XX] — e.g., M-99
- **Source Plan:** [docs/M-XX-name.md]
- **Date Created:** [YYYY-MM-DD]
- **Total Slices:** [N]
- **Current Slice:** 0 — not started
- **Current Branch:** [current-local-branch-name]
- **Author:** loop-engineering skill
```

Rules:
- If slices are **explicit** in the plan, OMIT the two `Inferred Slices` comment lines entirely.
- If slices are **inferred**, those two lines MUST be the first two lines of the file.
- `Current Slice: 0` before execution starts; updated after each slice completes (1..N).

---

## B2 — Module Summary & Validation Gates

```markdown
## Module Summary

[1–3 sentences: what the module does, who the user is, and the done-criteria in one end-to-end sentence. Copy verbatim or paraphrase from the plan.]

## Global Validation Gates

- Gate G0 (pre-execution): `build` passes zero errors + zero warnings, `tests` pass 100%.
- Gate G1 (post-execution per slice): same as G0 plus slice-specific gate below.

## Slice Validation Gates (from plan, or inferred)

| Slice | Gate ID | Gate Description | How to Verify |
|-------|---------|------------------|---------------|
| 1 | VG-01 | [e.g., DB migration applies cleanly; SELECT on users succeeds] | [e.g., run migration, query] |
| 2 | VG-02 | [e.g., POST /api/register returns 201 for valid payload] | [e.g., curl + assert] |
| 3 | VG-03 | [e.g., POST /api/login returns JWT; GET /me with JWT succeeds] | [e.g., integration test] |
| ... | VG-0N | [gate for slice N] | [verification command] |
```

Rules:
- If the plan lists no explicit validation gate for a slice, write `Manual verification: demo the slice end-to-end; document result`.
- Do not leave any cell empty — write `N/A — manual demo` if truly not verifiable automatically.

---

## B3 — Slice Index (Single Source of Truth for Count)

```markdown
## Slice Index

| # | Slice Title | Status | Validation Gate |
|---|-------------|--------|-----------------|
| 1 | [Slice 1 title — verbatim from plan] | [ ] Not started | VG-01 |
| 2 | [Slice 2 title] | [ ] Not started | VG-02 |
| 3 | [Slice 3 title] | [ ] Not started | VG-03 |
| ... | ... | ... | ... |
| N | [Slice N title] | [ ] Not started | VG-0N |
```

Rules:
- Row count MUST equal `Total Slices` in B1.
- `Status` values allowed: `[ ] Not started`, `[~] In progress (Stage X/10)`, `[x] Done`.
- Initially all rows are `[ ] Not started`.

---

## B4 — Per-Slice 10-Stage Checklists

> Repeat this block for **each** slice. Each checkbox starts as `- [ ]`. The 10 stages MUST appear in order and must not be merged.

```markdown
## Slice 1: [Slice 1 Title]

- **Goal:** [One sentence: what user-visible value this slice delivers.]
- **Touches:** [UI files / API files / DB files — list concrete paths or TBD if unknown]
- **Validation Gate:** VG-01 — [gate description]

### 10-Stage Progress

- [ ] **Stage 1 — Pre-Execution Verification:** Build passes `zero errors + zero warnings` and all tests pass. Evidence: [command + output hash/log path]
- [ ] **Stage 2 — Deep Understanding:** Requirements, inputs, outputs, edge cases documented. Notes: [link or inline]
- [ ] **Stage 3 — File Analysis:** Every file this slice touches listed and inspected. Files: [list]
- [ ] **Stage 4 — Planning:** Step-by-step execution plan written. Plan: [link or inline checklist]
- [ ] **Stage 5 — Execution:** Slice implemented per plan.
- [ ] **Stage 6 — Post-Execution Verification:** Build + tests pass again `zero errors + zero warnings`.
- [ ] **Stage 7 — Validation Gate:** VG-01 passed. Evidence: [command/output]
- [ ] **Stage 8 — Documentation Update:** Every checkbox in this slice marked [x] where applicable.
- [ ] **Stage 9 — Memory Status Update:** "Current Status" section updated.
- [ ] **Stage 10 — Git Commit (Draft + Human Confirmation):** Staged (`git add`), commit message drafted per template, awaiting explicit human confirmation before `git commit`/`git push`; never auto-commit/push. Draft: [message] — Status: [pending confirmation] — Commit: [pending, no hash until confirmed]

---

## Slice 2: [Slice 2 Title]

- **Goal:** [sentence]
- **Touches:** [files]
- **Validation Gate:** VG-02 — [description]

### 10-Stage Progress

- [ ] **Stage 1 — Pre-Execution Verification:** ...
- [ ] **Stage 2 — Deep Understanding:** ...
- [ ] **Stage 3 — File Analysis:** ...
- [ ] **Stage 4 — Planning:** ...
- [ ] **Stage 5 — Execution:** ...
- [ ] **Stage 6 — Post-Execution Verification:** ...
- [ ] **Stage 7 — Validation Gate:** ...
- [ ] **Stage 8 — Documentation Update:** ...
- [ ] **Stage 9 — Memory Status Update:** ...
- [ ] **Stage 10 — Git Commit (Draft + Human Confirmation):** Staged, draft pending — see Slice 1 template; never auto-commit/push.

---

## Slice N: [Slice N Title]

- **Goal:** [sentence]
- **Touches:** [files]
- **Validation Gate:** VG-0N — [description]

### 10-Stage Progress

- [ ] **Stage 1 — Pre-Execution Verification:** ...
- [ ] **Stage 2 — Deep Understanding:** ...
- [ ] **Stage 3 — File Analysis:** ...
- [ ] **Stage 4 — Planning:** ...
- [ ] **Stage 5 — Execution:** ...
- [ ] **Stage 6 — Post-Execution Verification:** ...
- [ ] **Stage 7 — Validation Gate:** ...
- [ ] **Stage 8 — Documentation Update:** ...
- [ ] **Stage 9 — Memory Status Update:** ...
- [ ] **Stage 10 — Git Commit (Draft + Human Confirmation):** Staged, draft pending — see Slice 1 template; never auto-commit/push.
```

Rules:
- Every slice block must keep all 10 stages; never shorten to 8 or 9.
- Stage 1 and Stage 6 forbid "warnings are OK" — text must remain `zero errors + zero warnings`.
- Do not truncate with `...` in the final memory file — the template shows `...` as placeholder only; generated file must expand fully.

---

## B5 — Current Status & Execution Log

```markdown
## Current Status

- Overall: [0/N slices done | 1/N done | ... | N/N done]
- Slice 1 — [Slice Title]: [ ] Not started
- Slice 2 — [Slice Title]: [ ] Not started
- Slice 3 — [Slice Title]: [ ] Not started
- ...
- Slice N — [Slice Title]: [ ] Not started

> The Current Status section MUST contain exactly N+1 lines (1 Overall + N slice lines). Never replace lines with "..." or "and so on". Never abbreviate.

## Execution Log

| Date (YYYY-MM-DD) | Slice | Stage | Action | Result | Commit |
|-------------------|-------|-------|--------|--------|--------|
| [YYYY-MM-DD] | 0 | — | Memory file created | OK | — |
| [YYYY-MM-DD] | 1 | 1 | Pre-Execution Verification | PASS — zero warnings | — |
| ... | ... | ... | ... | ... | ... |

## Stop Report (append only if a stop condition triggers)

```markdown
## Stop Report — 2026-09-02

- **Slice:** [N]
- **Failing Action:** [build / test / file modification / same error]
- **Attempt Count:** 4 consecutive
- **Last Error:** [verbatim last error message]
- **Affected Files:** [list]
- **Next Step:** Awaiting manual fix — loop halted per stop-conditions.md
```
```

### Final Validation Checklist (before saving the memory file)

- [ ] File is 100% English (Arabic only allowed in the 5-line summary AFTER the two code blocks, not inside this file).
- [ ] Date is ISO 8601 `YYYY-MM-DD`.
- [ ] `Total Slices` matches row count in B3 and block count in B4 and line count-1 in B5 Current Status.
- [ ] Every checkbox is `- [ ]` (unfilled) at creation time.
- [ ] Current Status has exactly N+1 lines, fully enumerated.
- [ ] No placeholder text remains such as `TODO`, `TBD` without context, `...`, `and so on`, `[...]`.
- [ ] Validation gates copied verbatim from plan or explicitly marked as inferred.

---

### Example Filled Header (3 slices, explicit — no inference)

```markdown
# Loop Engineering — Memory File

- **Module:** User Authentication
- **Module Number:** M-99
- **Source Plan:** docs/M-99-user-auth.md
- **Date Created:** 2026-09-02
- **Total Slices:** 3
- **Current Slice:** 0 — not started
- **Current Branch:** main
- **Author:** loop-engineering skill
```
