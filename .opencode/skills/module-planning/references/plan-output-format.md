# Plan Output Format

The final plan file must follow this structure:

```markdown
# Module M-[Number] — [Module Name]: Implementation Plan

**Target Framework:** [e.g., net8.0]
**Architecture:** [e.g., Clean Architecture]
**Patterns:** [e.g., MediatR CQRS, FluentValidation]

---

## Executive Summary

[1-2 paragraphs: what the module does, entities involved, layers touched]

**Scope:** This plan covers Domain, Application, Infrastructure, and any other non-UI layers. It does NOT cover WPF views, XAML, ViewModels, or any Presentation-layer GUI work.

---

## Slice S[N] — [Slice Name]

### Description
[What this slice implements]

### Files to Create/Modify
| File | Action | Purpose |
|------|--------|---------|
| [path] | Create/Modify | [purpose] |

### Technical Approach
[Code patterns, algorithms, design decisions]

### Dependencies
[Which previous slices this depends on]

### Validation Gate
[Specific, testable criteria for success]

### Risk Level
[Low/Medium/High]

---

## Dependency Graph
[Execution order diagram]

---

## Edge Cases
| ID | Edge Case | Expected Behavior |
|----|-----------|-------------------|

---

## Risks
| ID | Risk | Impact | Mitigation |
|----|------|--------|------------|

---

## Decisions Log
| ID | Decision | Rationale | Status |
|----|----------|-----------|--------|

---

## Uncertainties
| ID | Uncertainty | Impact | Resolution |
|----|------------|--------|------------|
```

---

## Rules:

1. Slice count: Determined by the Planner based on functional requirements. No minimum, no maximum.
2. Each slice must be independently testable
3. Risk-ordered delivery (highest risk first)
4. Follow existing codebase patterns exactly
5. Never assume requirements — ask if unclear
6. All file paths must be verified against codebase
7. All decisions must be documented with rationale
8. **No UI/GUI content** — plan covers Domain, Application, Infrastructure only. Zero references to WPF views, XAML, ViewModels, windows, UserControls, or DataTemplates.
