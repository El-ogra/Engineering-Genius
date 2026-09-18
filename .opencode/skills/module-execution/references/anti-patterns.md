# Anti-Patterns — Loop Engineering

> Specific failure modes the implementing agent MUST avoid. Each entry has a self-check you can run to detect whether you have fallen into the pattern.

---

## AP-01 — Stage Skipping

- **Name:** Stage Skipping
- **What it looks like:** Going straight from "I understand the slice" to code edits, skipping Pre-Execution Verification (Stage 1) or File Analysis (Stage 3) because "the build was green yesterday" or "I know which files to touch."
- **Why it fails:** IID's core guarantee is a green baseline before incrementing. Without Stage 1 you cannot attribute a later failure to the current slice; a pre-existing red baseline will be misdiagnosed as your fault, wasting retries and eventually tripping the stop condition erroneously.
- **How to detect:** Self-check: can you paste the exact build command output and timestamp for Stage 1 of the current slice? If not, you skipped it. Mandatory evidence: build log path or terminal hash.

---

## AP-02 — Stage Merging

- **Name:** Stage Merging
- **What it looks like:** Marking Stages 6+7 as one step ("build+gate passed") or Stages 8+9+10 as one commit ("docs+status+push done together" without separate checklist marks).
- **Why it fails:** Merged stages hide which verification actually failed. PDCA requires separate Check (Stage 6: technical) and Check (Stage 7: user-visible validation) — collapsing them removes the distinction between "tests pass but user journey is broken" (a common vertical-slice bug).
- **How to detect:** Count the checkbox marks in the memory file for the current slice. If fewer than 10 distinct `- [x]` lines exist per slice, you merged. Each stage must have its own line.

---

## AP-03 — Premature Checkbox Completion

- **Name:** Premature Checkbox Completion (Optimistic Marking)
- **What it looks like:** Marking `- [x] Stage 6 — Post-Execution Verification` before the build actually runs, or marking Stage 7 as passed because "it should work given Stage 5 edits."
- **Why it fails:** The memory file becomes a lie; later audits assume verification happened. Violates Continuous Integration's "Make the Build Self-Testing" — verification must be evidence-based, not assumption-based.
- **How to detect:** For every `[x]` in the memory file, an associated evidence field must be filled (command, log path, or commit hash). Any `[x]` with empty evidence is premature.

---

## AP-04 — Zero Warnings Downgrade

- **Name:** Zero Warnings Downgrade
- **What it looks like:** Changing the success criterion from "zero errors + zero warnings" to "zero errors; warnings are OK" or silencing warnings with `-Wno-...` / `<NoWarn>` / `// eslint-disable` without fixing the underlying issue.
- **Why it fails:** Warnings accumulate into technical debt; Trunk-Based Development's fast green build degenerates. More importantly, the loop's stop condition becomes unreliable — a sliced build that "passes with warnings" will mask the real signal when a later slice introduces a genuine warning-worthy defect.
- **How to detect:** Search the build output for the string `warning` (case-insensitive). Any occurrence = failure, regardless of exit code 0. Self-check: did you run with `-warnaserror` / equivalent strict mode?

---

## AP-05 — Remote Push Violation

- **Name:** Remote Push Violation
- **What it looks like:** Pushing to `origin/main` when the current branch is `feature/M-07`, or creating a new remote branch via `git push -u origin new-slice-branch`, or pushing to `origin` when the loop policy says "current local branch only."
- **Why it fails:** Breaks Trunk-Based Development's release-from-trunk model and pollutes remote history. Reverts become cross-branch operations. Also violates the explicit Strict Branch Policy in `SKILL.md`.
- **How to detect:** Before pushing, run `git branch --show-current` and `git remote show origin` (or `git status -b`). The push refspec must be `HEAD` → `origin/<current-branch>`. Any `new branch` message in push output is a violation.

---

## AP-06 — Current Status Truncation

- **Name:** Current Status Truncation
- **What it looks like:** Writing:
  ```
  ## Current Status
  - Overall: 1/5 done
  - Slice 1: Done
  - ...
  ```
  or "Slice 2–5: pending — see above" or "and so on."
- **Why it fails:** The memory file is the loop's single source of truth for progress (Shape Up Hill Chart analog). Truncation destroys the ability to enumerate slice state programmatically or via code review, violating the Critical Reminders rule that Current Status MUST contain all N+1 lines fully enumerated.
- **How to detect:** Count lines under `## Current Status` until the next `##`. For N slices, the count must be exactly N+1 non-empty bullet lines, each naming a slice title verbatim. If any line contains `...`, `…`, `and so on`, or `etc`, you truncated.

---

## AP-07 — Hallucinated Memory File

- **Name:** Hallucinated Memory File (Plan Empty / No Slices)
- **What it looks like:** The plan file is empty, contains only `# Module` header, or lists no slices, yet the agent still emits a memory file with invented slices like "Set up project, Build API, Build UI" without marking them as inferred.
- **Why it fails:** IID requires that increments derive from the Project Control List — hallucinating slices means building without a control list, which is indistinguishable from ad-hoc hacking. Also violates the Anti-Hallucination Guard policy.
- **How to detect:** The generating skill must validate: does the raw plan contain ≥3 distinct slice-like entries (numbered list, `Slice` headings, or checkbox items)? If not, the correct output is the Arabic guard message, not a memory file. If you are about to emit a memory file and the plan had zero identifiable slices that were not produced by the 6-rule heuristic, you are hallucinating — STOP.

---

## AP-08 — Silent Heuristic Inference

- **Name:** Silent Heuristic Inference
- **What it looks like:** Applying the 6-rule heuristic to infer 3–7 slices but NOT adding the required header lines `# Inferred Slices: [N] (via vertical-slicing heuristic)` and `# Note: Slice boundaries inferred...` to the memory file.
- **Why it fails:** Downstream reviewers cannot distinguish inferred (uncertain) slices from explicit (authoritative) slices. Shape Up's "bounded" property requires explicit acknowledgment of inference so the team can adjust before execution.
- **How to detect:** If the plan had no explicit slice numbering, search the memory file's first 5 lines for the string `Inferred Slices`. If absent, you silently inferred.

---

## AP-09 — Horizontal Slice in Vertical Clothing

- **Name:** Horizontal Slice in Vertical Clothing
- **What it looks like:** A slice titled "Database schema for users" that only creates tables and migrations, with no Application-layer logic, yet claiming to be a vertical slice.
- **Why it fails:** Violates vertical slicing's core definition: a true vertical slice must be user-valuable and cut through architectural layers (Domain+Application+Infrastructure). Horizontal slices deliver zero user value until all layers are later assembled, reintroducing the waterfall risk the loop is designed to avoid.
- **Scope note:** In this codebase, the Presentation/View layer (WPF XAML, ViewModels) is explicitly OUT of scope for planning. Vertical slices go through Domain→Application→Infrastructure only.
- **How to detect:** For each slice, test: does the slice deliver user-visible value when the Domain, Application, and Infrastructure layers are assembled? If the slice only touches one layer (e.g., "create migration only" or "add DTO only" without any handler or entity), the slice is too narrow — combine it with the layer above and below to form a meaningful vertical increment.

---

## AP-10 — Placeholder & Truncation Residue

- **Name:** Placeholder & Truncation Residue
- **What it looks like:** Memory file or execution prompt contains strings like `TBD`, `TODO`, `FIXME`, `[PLACEHOLDER]`, or `...` in any generated artifact (except where `TBD` is explicitly allowed as a transient File Analysis note meaning "to be determined before execution").
- **Why it fails:** Violates Critical Reminders: "Zero placeholders. Zero truncation. Copy-pasteable with one click." A placeholder forces manual editing before use, breaking automation and introducing interpretation drift between planners and implementers.
- **How to detect:** Grep the generated artifacts for regex `TBD|TODO|FIXME|\[PLACEHOLDER\]|\.{3}|…` (and for truncated status lines, also search for `and so on` / `etc.`). Any match outside an explicitly allowed exception is a failure.

---

## AP-11 — One-Click Copy-Paste Violation

- **Name:** One-Click Copy-Paste Violation
- **What it looks like:** Emitting the memory file across multiple fragmented code blocks, or interleaving commentary between the two required blocks, or requiring the user to stitch fragments.
- **Why it fails:** The Generate Two Artifacts rule mandates EXACTLY two fenced code blocks in strict order with NOTHING between them. Fragmentation breaks the skill's contract — the implementing agent cannot reliably extract artifacts.
- **How to detect:** Count fenced code blocks in the skill's response. Exactly two. Verify first block is the memory file, second is the execution prompt. Any explanatory text between the blocks is a violation.

---

## Self-Audit Checklist (run before emitting anything)

- [ ] Each slice has 10 distinct stages, 10 distinct checkboxes?
- [ ] Build criterion remains `zero errors + zero warnings` verbatim?
- [ ] Current Status has N+1 fully enumerated lines, no `...`?
- [ ] No `TBD`/`TODO`/`...` residues?
- [ ] Branch policy respected (no new branches, no foreign remote pushes)?
- [ ] If plan was empty/unparseable, did you emit the Arabic guard message instead of a memory file?
- [ ] If you inferred slices, do the two `Inferred Slices` header lines exist?
- [ ] Each slice cuts through Domain+Application+Infrastructure (Presentation/View layer is explicitly out of scope)?
