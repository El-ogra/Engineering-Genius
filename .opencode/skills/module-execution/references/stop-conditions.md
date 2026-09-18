# Stop Conditions — Loop Engineering

> Normative rules for when the loop MUST halt. Mirrors the SKILL.md Strict Policies table but with counting precision, definitions, and worked examples.

---

## Overview

The loop halts when any ONE of the four conditions reaches **4 consecutive failures**. A halt is not a retry suggestion — it is a full stop. The agent must emit a status report and wait for manual intervention.

Threshold: **4** (not 3, not 5). Consecutive: uninterrupted sequence of the *same* failure mode for the *same* slice/stage. Any *new* error (different normalized message) or *success* resets the counter for that condition.

---

## Condition 1 — Build Failure

- **Trigger:** `build` command exits non-zero (e.g., `dotnet build` returns error, `npm run build` fails, `make` fails).
- **How to count:** Each invocation that ends non-zero increments the counter. An invocation that succeeds (exit 0 AND zero warnings) resets the counter to 0 for this condition.
- **Same error vs new error:** For build failures, "same error" grouping is NOT required — any build failure counts toward this condition's consecutive sequence. A different compilation error still increments.
- **Threshold:** 4 consecutive build failures for the same slice.
- **Action:** STOP. Emit stop report. Do not attempt a 5th build silently.

### Example 1a — Halts

- Attempt 1: `dotnet build` → `error CS0246: The type or namespace name 'Foo' could not be found`
- Attempt 2: `dotnet build` → `error CS0246: The type or namespace name 'Foo' could not be found` (after an ineffective fix)
- Attempt 3: `dotnet build` → `error CS0246: The type or namespace name 'Foo' could not be found`
- Attempt 4: `dotnet build` → `error CS0246: The type or namespace name 'Foo' could not be found`
- → **STOP** — 4 consecutive build failures, even though only one error type.

### Example 1b — Resets

- Attempt 1: `dotnet build` → fail (A)
- Attempt 2: `dotnet build` → success (counters reset)
- Attempt 3: `dotnet build` → fail (counter = 1 again, not 3)

---

## Condition 2 — Same Error Unfixed

- **Trigger:** The same logical error persists across attempts, regardless of which sub-stage emits it (could be build error message, test failure message, or validation gate output).
- **How to count:** Normalize the error before comparing:
  - Trim timestamps, durations (e.g., `7ms` in TDD output), absolute paths, commit hashes, and PIDs.
  - Compare the remaining message verbatim.
  - If normalized messages match, they are the "same error"; otherwise they are "new errors" (and do not count toward the same-error sequence, but may count toward Condition 1/3).
- **Threshold:** 4 consecutive occurrences of the *normalized* same error.
- **Action:** STOP even if Stage 6 and Stage 7 alternate — if the root cause message is identical, the loop is stuck.

### Example 2a — Halts

- Attempt 1: `FAIL test_email_validator.py::test_accepts_valid_email — ModuleNotFoundError: No module named 'email_validator'`
- Attempt 2: (after creating empty file) → `FAIL test_email_validator.py::test_accepts_valid_email — AssertionError: assert True is False` — WAIT this is a different normalized message, so counter for *same error* resets.
- Attempt 3–6: `AssertionError: assert True is False` repeats 4 times without change → **STOP** on attempt 6 (fourth repeat of that normalized message).

### Example 2b — Does NOT halt (new error each time)

- Attempt 1: `error CS1002: ; expected`
- Attempt 2: `error CS1525: Invalid expression term '}'`
- Attempt 3: `error CS0103: The name 'foo' does not exist`
- Attempt 4: `warning CS0219: Variable assigned but never used` (but warnings = failures, so counts for Condition 1)
- These are 4 failures but NOT the same normalized error, so Condition 2 does not halt. However Condition 1 DOES halt at 4 (any build failure). If Condition 1 were not applicable, Condition 2 would require the *identical* message.

---

## Condition 3 — Test Failure

- **Trigger:** `tests` command exits non-zero or reports any test case failure (including 1 failing out of N).
- **How to count:** Each full test-suite run that has ≥1 failing test increments the counter. A run where all tests pass (and build still zero warnings) resets the counter.
- **Same error vs new error:** For counting toward Condition 3, any test failure counts — same gate as Condition 1 logic. Condition 2's "same error" rule is a separate check; a single sequence of test failures can trigger *either* Condition 2 (same message 4×) or Condition 3 (any test failure 4×), whichever hits first.
- **Threshold:** 4 consecutive test-suite failures.
- **Action:** STOP.

### Example 3a — Halts

- Run 1: `npm test` → `FAIL src/login.test.ts — TypeError: cannot read property 'token' of undefined` (2 tests failed)
- Run 2: (fix attempt) → same suite → `FAIL src/login.test.ts — 1 test failed (same file)` → count 2
- Run 3: → fail → count 3
- Run 4: → fail → count 4 → **STOP**

### Example 3b — Resets

- Run 1: `npm test` → fail
- Run 2: `npm test` → fail
- Run 3: `npm test` → PASS (reset)
- Run 4: `npm test` → fail (counter = 1, not 4)

---

## Condition 4 — Same File Modification Failure

- **Trigger:** Repeated failure to modify the *same* file. This includes:
  - Patch/apply failure (`error: patch does not apply`, `conflict`)
  - Linter/formatter rejection that blocks the edit
  - Permission / locked file / "file not found" on write
  - Tooling error when generating code into that file
- **How to count:** Track per-file. If 4 consecutive attempts all target the same file path and all fail (even with slightly different error messages), halt. If the agent switches to a different file and fails there, the per-file counter for the previous file pauses (does not reset) — but the overall loop is still not making progress; however the strict halt requires 4 consecutive for the *same* file.
- **Threshold:** 4 consecutive failures targeting the same file path.
- **Action:** STOP.

### Example 4a — Halts

- Attempt 1: write `src/UsersService.cs` → `Error: File is read-only`
- Attempt 2: write `src/UsersService.cs` → `Error: File is read-only` (did not fix permissions)
- Attempt 3: write `src/UsersService.cs` → `Error: File is read-only`
- Attempt 4: write `src/UsersService.cs` → `Error: File is read-only`
- → **STOP** — same file, 4 consecutive write failures.

### Example 4b — Does NOT yet halt (switched files)

- Attempt 1: write `src/A.cs` → fail
- Attempt 2: write `src/B.cs` → fail (counter for A is paused at 1; counter for B is 1)
- Attempt 3: write `src/A.cs` → fail (counter for A = 2)
- Attempt 4: write `src/A.cs` → fail (counter for A = 3, not yet 4)
- Need one more consecutive failure on `src/A.cs` to halt under Condition 4. However Conditions 1/2/3 may already have halted.

---

## Counting Rules (Normative)

1. **Consecutive means unbroken.** Any success (build PASS with zero warnings, tests PASS) resets the counter for Conditions 1 and 3. Any *different* normalized error message resets the counter for Condition 2. Any attempt on a *different* file resets (pauses) Condition 4's per-file chain for the previous file.
2. **Normalization for Condition 2:** Before comparing two errors, strip:
   - Absolute paths → keep only relative `src/...` suffix
   - Timestamps / durations / ms values / PIDs
   - Commit hashes / run IDs
   - Whitespace normalization (trim, collapse multiple spaces)
3. **Scope of counting:** Counters are **per-slice and per-stage-context**. Moving to the next slice resets all counters. However, failures during Stage 1 (pre-verification) do NOT count toward a slice's stop condition — Stage 1 is outside the slice's 4-attempt budget.
4. **Do not conflate conditions:** 2 build failures + 2 test failures ≠ 4 consecutive. Each condition tracks its own sequence.
5. **Report even if you think you know the fix:** After the 4th consecutive failure, you must emit the report. Do not attempt a 5th fix silently.

---

## Status Report Format (Exact)

When any condition halts the loop, emit exactly this structure (fill ALL fields, no placeholders):

```
## Stop Report — Loop Halted

- **Module:** [M-XX] [MODULE_NAME]
- **Slice:** [N/N] — [Slice Title]
- **Failing Action:** [build | test | same error | file modification — plus stage number, e.g., Stage 6 Post-Execution Verification]
- **Attempt Count:** 4 consecutive
- **Last Error:** [verbatim last error message, normalized only for comparison but reported verbatim, trimmed to 30 lines max if longer but NOT replaced with "..."]
- **Affected Files:** [comma-separated list of relative paths touched in this slice attempting to fix]
- **Stages Completed:** [e.g., Stages 1-5 of Slice 2 completed; Stage 6 failing]
- **Next Step:** Manual intervention required. Loop halted per stop-conditions.md. Do not auto-retry.
```

And also append a `## Stop Report — YYYY-MM-DD` entry to the memory file's `## Execution Log` / `## Stop Report` section.

### Worked Example — Full Halt Report

```
## Stop Report — Loop Halted

- **Module:** M-07 User System
- **Slice:** 2/5 — Registration API endpoint with validation
- **Failing Action:** test — Stage 6 Post-Execution Verification (4 consecutive `dotnet test` failures)
- **Attempt Count:** 4 consecutive
- **Last Error:** Failed! — Failed: 3, Passed: 12, Skipped: 0, Total: 15, Duration: 234 ms — src/Auth/RegisterTests.cs(42): Assert.Equal() Failure: Expected 201 but was 400
- **Affected Files:** src/Auth/RegisterEndpoint.cs, src/Auth/RegisterValidator.cs, tests/RegisterTests.cs
- **Stages Completed:** Stages 1-5 of Slice 2 completed; Stage 6 consistently failing
- **Next Step:** Manual intervention required. Loop halted per stop-conditions.md. Do not auto-retry.
```

---

## Interaction With Other Policies

- **Branch policy still applies during halt:** Do not push partial failed work to remote. Even the halt report commit (if any) requires explicit human confirmation before `git commit`/`git push` and goes to the current local branch only when confirmed. No auto-push of halt reports.
- **Anti-patterns still apply:** Do not mark the failing slice as `[x] Done` in the memory file when halted. Leave it as `[~] In progress (Stage 6/10)`.
- **Human-confirmation policy:** Throughout halt handling, the owner personally handles all git commits — Stage 10's "draft then await confirmation" rule is not waived for stop reports.
- **Resumption:** After manual fix, reset all counters to 0 and re-enter at the stage that failed (typically Stage 6). Re-run Pre-Execution Verification if the fix touched multiple files outside the slice.
```
