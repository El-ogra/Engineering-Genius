# Planning Phase — Detailed Workflow

## Step 1: Requirements Gathering

### Human Provides:
1. Module Name/Number
2. Functional Description (FRs, BRs)
3. Dependencies (other modules)
4. Constraints (architecture, tech)
5. Acceptance Criteria

### Agent Saves To:
`docs/plans/[module-name]-requirements.md`

---

## Step 2: Multi-Agent Planning

### Agent 1: Planner (`dotnet-architect`)

**Input:** Requirements from Step 1

**Output:** Draft plan with:
- Module overview
- Slice breakdown (count determined by functional needs, no min/max)
- Dependencies between slices
- Technical approach for each slice (files to create/modify)
- Risk assessment
- Validation gates per slice

**Scope constraint:** Only Domain, Application, Infrastructure layers. No UI/GUI/Views/ViewModels.

**Save To:** `docs/plans/[module-name]-draft.md`

### Agent 2: Auditor (`dotnet-code-review-agent`)

**Input:** Draft plan from Agent 1

**Review Checklist:**
1. Are all FRs covered?
2. Are slices properly independent?
3. Are dependencies correctly identified?
4. Are risks identified with mitigations?
5. Are validation gates specific and testable?
6. Are file paths correct (match codebase conventions)?
7. Are architecture rules followed?
8. Is there zero UI/GUI content in the plan?

**Output:** Critique with:
- Critical issues (must fix)
- Important issues (should fix)
- Nice-to-have improvements
- Revised plan with fixes applied

**Save To:** `docs/plans/[module-name]-critique.md`

---

## Step 3: Human Decisions

### Human Reviews:
1. Draft plan
2. Critique
3. Makes decisions on open items

### Human Saves To:
`docs/plans/[module-name]-decisions.md`

---

## Step 4: Final Plan Generation

### Agent Action:
- Check if `Docs/OpenCode/` exists; create ONLY if missing
- Generate final clean plan from draft + critique + decisions
- No open decisions remaining
- Ready for execution

### Save To:
`Docs/OpenCode/M-[number].md`

---

## File Structure

```
docs/plans/
├── [module-name]-requirements.md
├── [module-name]-draft.md
├── [module-name]-critique.md
└── [module-name]-decisions.md

Docs/OpenCode/            ← created only if not already present
└── M-[number].md         ← Final plan for execution
```

---

## Stop Conditions

| Condition | Action |
|-----------|--------|
| Missing requirements | Ask human for clarification |
| Draft plan incomplete | Re-invoke planner with feedback |
| Critique has critical issues | Re-invoke planner with critique |
| Human decisions pending | Wait for explicit decisions |
| Plan contains UI/GUI content | Remove it before finalizing |
| Plan cannot be approved after 3 iterations | STOP and report |
