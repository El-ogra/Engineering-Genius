# Phase 0 — Integrated Local Planning

## Overview

Phase 0 is the planning stage that precedes the 10-stage execution loop. It uses multiple local agents to produce a high-quality, critique-validated implementation plan before any code is written.

## Trigger Phrases

This phase activates when the user's message includes:
- "خطط لـ [module name]" / "planning for [module name]"
- "ابدأ التخطيط" / "start planning"
- "صمم خطة تنفيذ" / "design implementation plan"
- Any request to create a plan before execution

## Workflow — 3-Step Process

### Step 1: Requirements Gathering (Human)

Before invoking any agent, the human must provide:

1. **Module Name/Number** — e.g., "Module 17", "Authentication System"
2. **Functional Description** — what the module should do
3. **Dependencies** — other modules or systems it depends on
4. **Constraints** — technical limitations, performance requirements
5. **Acceptance Criteria** — how to know when it's done

**Output**: A requirements document saved to `docs/requirements/[module-name]-requirements.md`

### Step 2: Multi-Agent Planning (Local Agents)

Invoke two agents sequentially:

#### Agent 1: Planner (`@dotnet-architect` or equivalent)

**Role**: Create the initial implementation plan

**Input**: Requirements document from Step 1

**Output**: Draft plan with:
- Module overview
- Slice breakdown (3-7 slices)
- Dependencies between slices
- Technical approach for each slice
- Risk assessment

**Save to**: `docs/plans/[module-name]-draft.md`

#### Agent 2: Critic (`@dotnet-code-review-agent` or equivalent)

**Role**: Review and improve the draft plan

**Input**: Draft plan from Agent 1

**Instructions**:
```
You are a plan critic. Review this implementation plan and provide:

1. **Issues Found** — What's missing, unclear, or risky
2. **Suggestions** — Specific improvements for each issue
3. **Risk Mitigation** — How to address identified risks
4. **Slice Validation** — Are slices properly independent?
5. **Dependency Check** — Are dependencies correctly identified?

For each issue, provide:
- Issue description
- Why it's a problem
- Recommended fix
- Impact if not fixed

Output format:
## Critique Summary
[Overall assessment]

## Issues by Priority
### Critical (Must Fix)
- [Issue 1]: [Description] → [Fix]

### Important (Should Fix)
- [Issue 2]: [Description] → [Fix]

### Nice to Have
- [Issue 3]: [Description] → [Fix]

## Revised Plan
[The plan with all fixes applied]
```

**Save to**: `docs/plans/[module-name]-critique.md`

### Step 3: Final Plan Generation (Human + Agent)

**Human Action**:
1. Review both draft and critique
2. Make decisions on open items
3. Document decisions in `docs/plans/[module-name]-decisions.md`

**Agent Action** (after decisions are made):
- Generate final clean plan
- No open decisions remaining
- Ready for execution

**Save to**: `docs/[module-name]-plan.md` (final location for loop-engineering)

## File Structure

```
docs/
├── requirements/
│   └── [module-name]-requirements.md
├── plans/
│   ├── [module-name]-draft.md
│   ├── [module-name]-critique.md
│   └── [module-name]-decisions.md
└── [module-name]-plan.md  ← Final plan for execution
```

## Agent Invocation Commands

### For Planner Agent:
```
@dotnet-architect

أنت وكيل مخطط. قم بمراجعة متطلبات الوحدة الوظيفية التالية وإنشاء خطة تنفيذ:

[الصق المتطلبات هنا]

قدم خطة تحتوي على:
1. نظرة عامة على الوحدة
2. تقسيم الشرائح (3-7 شرائح)
3. التبعيات بين الشرائح
4. النهج الفني لكل شريحة
5. تقييم المخاطر

احفظ النتيجة في docs/plans/[module-name]-draft.md
```

### For Critic Agent:
```
@dotnet-code-review-agent

أنت وكيل ناقد. قم بمراجعة خطة التنفيذ التالية وتقديم تقييم نقدي:

[الصق خطة التنفيذ هنا]

قدم:
1. المشاكل المكتشفة
2. التحسينات المقترحة
3. تخفيف المخاطر
4. صحة تقسيم الشرائح
5. التحقق من التبعيات

احفظ النتيجة في docs/plans/[module-name]-critique.md
```

## Integration with Loop Engineering

After Phase 0 completes:

1. **Final plan** is at `docs/[module-name]-plan.md`
2. **Invoke loop-engineering**: `لوب إنجنيرنغ [module-name]-plan.md`
3. **Execution begins** with the 10-stage loop

## Anti-Hallucination Rules for Planning

1. **Never assume requirements** — If unclear, ask the human
2. **Never skip critique** — Every plan must be reviewed
3. **Never finalize without human decisions** — Open items require explicit approval
4. **Never mix planning and execution** — Complete Phase 0 before starting Stage 1

## Validation Gates for Phase 0

| Gate | Criteria | Pass Condition |
|------|----------|----------------|
| G0.1 | Requirements complete | All 5 items provided |
| G0.2 | Draft plan exists | File created with valid structure |
| G0.3 | Critique complete | Issues identified and addressed |
| G0.4 | Human decisions made | All open items resolved |
| G0.5 | Final plan ready | Clean plan at correct location |

## Stop Conditions for Phase 0

| Condition | Action |
|-----------|--------|
| Missing requirements | Ask human for clarification |
| Draft plan incomplete | Re-invoke planner with feedback |
| Critique unresolved issues | Re-invoke planner with critique |
| Human decisions pending | Wait for explicit decisions |

## Example Workflow

```
User:خطط لوحدة المصادقة (Module 17)

Phase 0.1: Human provides requirements
→ Saved to docs/requirements/authentication-requirements.md

Phase 0.2: Planner agent creates draft
→ Saved to docs/plans/authentication-draft.md

Phase 0.3: Critic agent reviews
→ Saved to docs/plans/authentication-critique.md

Phase 0.4: Human makes decisions on open items
→ Saved to docs/plans/authentication-decisions.md

Phase 0.5: Final plan generated
→ Saved to docs/authentication-plan.md

Phase 1: Loop engineering begins
→ "لوب إنجنيرنغ authentication-plan.md"
```
