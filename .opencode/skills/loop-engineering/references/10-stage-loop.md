# 10-Stage Loop — Detailed Per-Stage Procedure

> Read this file when you need stage-level precision. SKILL.md gives the overview; this file is normative for execution.

Each slice MUST traverse stages 1→10 sequentially. No skipping, no merging, no reordering.

---

## Stage 1 — Pre-Execution Verification

**Procedure:** Run the project's build command (e.g., `dotnet build`, `npm run build`, `cargo build`, `mvn verify`, `make`) and the project's test command (e.g., `dotnet test`, `npm test`, `pytest`, `cargo test`) on the current branch before touching any file. Verify the output shows **zero errors and zero warnings** and all tests pass. If the build tool reports warnings as successes, treat any warning as a failure. Capture evidence (log path or terminal output snippet hash).

**Why (methodology source):** PDCA *Plan* and Martin Fowler's Continuous Integration — "Make the Build Self-Testing" + "Fix Broken Builds Immediately." IID requires a stable baseline before incrementing; without a green baseline you cannot attribute a failure to the current slice (Basili & Larman 2003). Trunk-Based Development also demands that trunk is green before new work.

**Failure modes:**
- Downgrading "zero warnings" to "warnings are OK" → masks real defects; later stages lose attribution.
- Running only build OR only tests → half-verification; integration defects slip through.

**If this stage fails:** Do not proceed. Fix the build/tests on the current branch first. This failure does NOT count toward the 4-consecutive stop condition for the slice (you have not started the slice) but must be resolved before Stage 2.

---

## Stage 2 — Deep Understanding

**Procedure:** Read the slice's section in the plan plus any linked requirements. Write a short internal note (in the memory file's Slice block or execution prompt) stating: (a) who the user is, (b) what input they provide, (c) what observable output/behavior they see, (d) what is explicitly out of scope for this slice, (e) validation gate for this slice. If any of (a)–(e) is unclear, mark the slice as ambiguous and halt — do not guess.

**Why:** IID's Project Control List and Shape Up's *Shaping* (appetite/boundaries) — work must be bounded and solved before betting. Vertical Slicing rule 1: a slice is a user-visible end-to-end test; you cannot slice correctly without understanding the user action.

**Failure modes:**
- Skipping this because "the slice title is obvious" → implements wrong scope, violates Independence heuristic rule 6.
- Confusing a horizontal layer task (e.g., "create table") for a vertical slice → Stage 7 validation gate will have no user-visible test.

---

## Stage 3 — File Analysis

**Procedure:** Enumerate every file the slice will create or modify (UI components, API handlers, DB migrations, configs, tests). Open and read each file. For existing files, note line counts and current contracts; for new files, note intended location and naming per project conventions. Record the list in the memory file's `Touches:` field. Invoke the `test-generation` skill here if available to scaffold tests for the files you listed.

**Why:** Shape Up "Map the Scopes" — organize by structure, not person; and Continuous Integration "Put everything in version-controlled mainline" — you must know the blast radius before changing it. Also directly supports the Slices Fallback heuristic rule 2 (layer crossing) — you prove the slice touches UI+API+DB.

**Failure modes:**
- Listing only the layer you are comfortable with (e.g., only backend) → violates vertical-slice principle, creates hidden integration risk.
- Not reading files before editing → breaks Trunk-Based Development's "Don't break the build" by introducing semantic conflicts auto-merge cannot catch.

---

## Stage 4 — Planning

**Procedure:** Write a numbered step-by-step plan for this slice inside the execution prompt or memory file. Each step must be atomic (one file or one concern), ordered by risk (highest-risk step first per heuristic rule 4), and end with a verification sub-step (e.g., "run X, expect Y"). The plan must reference the files from Stage 3 and the validation gate from Stage 2.

**Why:** PDCA *Plan* — determine goals and needed changes. Shape Up "Show Progress — Work is like a hill" — you track unknowns before execution. AIDS IID's increment planning (Larman/Basili initialization step).

**Failure modes:**
- Planning at layer granularity ("1. DB 2. API 3. UI") instead of vertical steps → reintroduces horizontal slicing.
- Plan without verification sub-steps → Stage 6 becomes "hope it works" rather than evidence-based.

---

## Stage 5 — Execution

**Procedure:** Execute the plan from Stage 4 in order, editing exactly the files listed. After each atomic step, run the relevant fast feedback command (e.g., `dotnet build`, `npm run lint`, single test file) before proceeding to the next step. Do not batch all edits then build once. Follow Red-Green-Refactor if TDD is in use: write failing test → make it pass → refactor.

**Why:** Red-Green-Refactor's Green phase (minimum code to pass) and IID's incremental implementation. Vertical slicing's Skateboard Principle — each slice is shippable; you only achieve that by building the slice thinly, not all layers upfront.

**Failure modes:**
- Editing files not in the plan without updating Stage 3/4 → untracked blast radius, violates branch policy attribution.
- Writing polished abstraction before the slice passes its validation gate → delays feedback, inverts risk order.

---

## Stage 6 — Post-Execution Verification

**Procedure:** Re-run the full build and full test suite exactly as in Stage 1. Expect `zero errors + zero warnings` and all tests green. This is not optional even if Stage 5's incremental checks passed. Capture evidence identical to Stage 1.

**Why:** PDCA *Check* — evaluate results against performance. Continuous Integration "Every Push to Mainline Should Trigger a Build" — verification before commit. This is the second anchor of the loop (Stage 1 + Stage 6) that makes the loop verifiable (IID's iterative feedback).

**Failure modes:**
- Skipping because "I ran tests after each step" → misses cross-slice integration failures that only the full suite catches.
- Accepting warnings as success → erodes the "Fix Broken Builds Immediately" discipline; warnings accumulate into debt.

**If this stage fails:** Fix the slice code; re-run Stage 6. Consecutive failures count toward the stop condition (4 consecutive test/build failures → halt).

---

## Stage 7 — Validation Gate

**Procedure:** Execute the slice's validation gate from B2. This must be an end-to-end, user-visible test (e.g., `POST /api/register` returns 201 + DB row exists + UI shows success, or `curl`-based check, or Playwright/Cypress journey). Do not substitute a unit-test pass for a validation-gate pass. Record the command and result in the memory file.

**Why:** Vertical Slicing's Invest criteria (Valuable, Testable) and Shape Up "Done means deployed" — a slice is only done when a user can complete one full action (heuristic rule 1). Directly implements IID's iteration analysis — does the increment deliver user value?

**Failure modes:**
- Treating Stage 6 (all tests green) as Stage 7 → misses that unit tests can be green while the user journey is broken.
- Manual gate with no evidence → unverifiable; later audit cannot confirm slice completeness.

**If no explicit gate exists in the plan:** Run a manual demo: start the app, perform the slice's user action, screenshot or log the observable outcome, and note `Manual verification: demo passed`.

---

## Stage 8 — Documentation Update

**Procedure:** In the memory file, mark every checkbox for this slice's 10-stage progress as `- [x]` (Stage 1 through Stage 8 now; Stages 9 and 10 will be marked as you complete them). Do not mark a stage `[x]` before its evidence exists. Also update any `Touches:` file list if new files were discovered during execution, and append the execution log row.

**Why:** PDCA *Act* — standardize the new method by updating standardized work. Continuous Integration "Everyone can see what's happening" — the memory file is the team's shared status (mirrors the Hill Chart in Shape Up).

**Failure modes:**
- Marking future stages early ("will be done") → destroys verifiability; audit thinks slice is ahead of reality.
- Forgetting to update `Touches:` → next slice's File Analysis misses dependencies.

---

## Stage 9 — Memory Status Update

**Procedure:** Update the `## Current Status` section in the memory file:
- Change `Overall:` from `X/N slices done` to `(X+1)/N`.
- Change the current slice's line from `[ ] Not started` to `[x] Done` (or `[~] In progress` if only mid-slice — but Stage 9 should occur after Stage 8, so typically Done).
- Increment `Current Slice:` in B1 to the next slice's number (or N if last slice).
- Verify the section still has exactly `N+1` lines (1 Overall + N slice lines) fully enumerated, no truncation.

**Why:** IID's Project Control List — the list is constantly revised in light of analysis results. Shape Up's Hill Chart tracking. This is also the anti-truncation guard: a truncated status lies about progress.

**Failure modes:**
- Replacing all slice lines with `...` or "Slice 4–N: pending" → violates Critical Reminders; loop tracker becomes useless.
- Updating Overall but not the per-slice line → inconsistent state; next agent misreads which slice is next.

---

## Stage 10 — Git Commit (Draft + Human Confirmation)

**Procedure:** Stage exactly the files changed in this slice (do not `git add .` blindly if unrelated files are dirty — review `git status`; use `git add <explicit-file-list>`). Draft the exact commit message per the template (do not commit yet):
```
[M-XX] Slice N/N: [Slice Title] — loop-engineering

Stages 1-10 verified. Gate [VG-0N] passed.
```
Then **STOP and request explicit human confirmation** before executing `git commit` or `git push`. Display the staged files (`git status --porcelain`) and the drafted message, and ask: `هل توافق على تنفيذ git commit و git push لهذه الشريحة؟ (نعم/لا)`. **Never** run `git commit` or `git push` implicitly or automatically under any condition — await the owner's `نعم/yes` reply. Only after human confirmation, commit and (if also confirmed) push to the **current local branch only** (`git push origin HEAD` targeting the local branch's upstream; never create a new branch, never push to a remote other than the current branch's origin tracking branch). Verify command exit code 0.

**Why:** Project practice: the owner personally handles all git commits, migration applications, and final verification — without exception. Trunk-Based Development's small commits still require human gating (Shape Up "Done means deployed" within the branch — but only after owner approval).

**Branch policy (normative):**
- Work ONLY on the current local branch (check `git branch --show-current` at Stage 1 and reuse it).
- NEVER `git checkout -b`, `git switch -c`, or `git push -u origin <new-branch>`.
- NEVER `git push origin remoteBranch:remoteBranch` where remoteBranch != current branch.
- NEVER auto-commit or auto-push — human confirmation is mandatory before any `git commit` or `git push`.
- If a push (after confirmation) would create a new remote branch, abort and report.

**Failure modes:**
- Pushing to `main` when you are on a feature branch (or vice versa) → remote pollution.
- Creating a new branch per slice → fragments history, breaks trunk-based flow.
- Committing unrelated dirty files → pollutes slice attribution; revert becomes hard.

---

### Stage Dependencies Diagram (conceptual)

```
1 PreVerify ──► 2 Understand ──► 3 FileAnalysis ──► 4 Plan ──► 5 Execute
                                                                    │
6 PostVerify ◄───────────────────────────────────────────────────────┘
      │
      ▼
7 Gate ──► 8 Docs ──► 9 Status ──► 10 Commit ──► (next slice Stage 1)
                                            │
                                            └──► if 4 consecutive failures at 6/7/10 → STOP per stop-conditions.md
```

### Emergency Stop

At any stage, if you encounter **4 consecutive failures** of the same action (build, test, same error, same file), STOP the loop and emit a Status Report per `stop-conditions.md`. Do not retry a fifth time silently.
