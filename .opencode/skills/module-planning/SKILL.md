---
name: module-planning
description: "Use this skill ONLY for PLANNING — when user says 'خطط لـ', 'ابدأ التخطيط', 'صمم خطة تنفيذ', 'planning for', or any request to CREATE a plan before execution. Produces ONE output: an approved, reviewed action-plan file. Covers every software layer EXCEPT UI/GUI/Presentation views. Must NOT write, modify, or touch any application source code."
license: MIT
compatibility: opencode
---

# Module Planning Skill

Produces a validated, multi-agent-reviewed implementation plan for a software module. Output is a single `.md` plan file — no code is written.

## When to Activate

This skill activates when the user's message matches:
- "خطط لـ [module name]" / "planning for [module name]"
- "ابدأ التخطيط" / "start planning"
- "صمم خطة تنفيذ" / "design implementation plan"
- Any request to create a plan before execution

Do NOT use for: executing an existing plan (use `module-execution` skill instead), ad-hoc scripts, design-only discussions.

## Scope Restriction — No UI/GUI/Presentation Views

The plan covers every relevant software layer:
- Domain (entities, value objects, domain events)
- Application (CQRS commands/queries, handlers, validators, DTOs, interfaces)
- Infrastructure (EF Core, repositories, external services)
- Any other non-UI layer required by the module

**The plan MUST NOT mention, describe, plan for, or reference any:**
- WPF views / XAML files
- Windows / UserControls
- ViewModels (these are Presentation layer)
- GUI-layer work of any kind
- DataTemplate mappings in App.xaml or any XAML resource dictionary

If a module requires UI work, the plan stops at the Application layer boundary. UI implementation is a separate concern handled outside this skill's output.

## Folder Handling — Conditional Creation

Before writing the final output, check whether `Docs/OpenCode/` already exists:
- If it does **not** exist: create it, then write the plan file.
- If it **already** exists: write the plan file directly — never recreate or overwrite the folder.

## Output File

Always `Docs/OpenCode/M-XX.md`, where `XX` is the module number provided by the owner. No other output location is used.

## Input Required from Human

Before invoking any agent, the human must provide:

1. **Module Name/Number** — e.g., "Module 17", "M-12"
2. **Functional Description** — what the module should do (FRs, BRs)
3. **Dependencies** — other modules it depends on
4. **Constraints** — technical limitations, architecture rules
5. **Acceptance Criteria** — how to know when it's done

## Workflow — 3-Step Process

### Step 1: Planner Agent

Invoke `dotnet-architect` (or `general`) with the requirements:

```
Task(subagent_type="dotnet-architect", prompt="
أنت وكيل مخطط. قم بإنشاء خطة تنفيذ مفصلة للوحدة التالية:

[المتطلبات]

قدم خطة تحتوي على:
1. نظرة عامة على الوحدة
2. تقسيم الشرائح (عدد الشرائح يُحدده المخطط بناءً على طبيعة الوحدة، لا يوجد حد أدنى أو أعلى)
3. التبعيات بين الشرائح
4. النهج الفني لكل شريحة (ملفات مُفصّلة)
5. تقييم المخاطر
6. شروط النجاح لكل شريحة

مهم جداً: الخطة تشمل فقط الطبقات غير الواجهة (Domain, Application, Infrastructure).
لا تذكر أي ملفات WPF أو XAML أو ViewModels أو أي أعمال واجهة مستخدم.

اتبع نمط الملفات الموجودة في Docs/OpenCode/ (مثل M-12.md).
احفظ النتيجة في docs/plans/[module-name]-draft.md
")
```

**Output:** Draft plan at `docs/plans/[module-name]-draft.md`

### Step 2: Auditor Agent

Invoke `dotnet-code-review-agent` with the draft:

```
Task(subagent_type="dotnet-code-review-agent", prompt="
أنت وكيل مراجع. قم بمراجعة خطة التنفيذ التالية وتقديم تقييم نقدي:

[محتوى خطة التنفيذ]

قدم:
1. المشاكل المكتشفة ( Critically / Important / Nice-to-have)
2. التحسينات المقترحة لكل مشكلة
3. التحقق من صحة تقسيم الشرائح
4. التحقق من التبعيات
5. الثغرات الأمنية المحتملة

مهم جداً: تأكد أن الخطة لا تحتوي على أي محتوى UI/GUI/Views.

إذا وجدت مشاكل حرجة: أعد الخطة مع التصحيحات.
إذا لا توجد مشاكل حرجة: أكّد أن الخطة جاهزة للتنفيذ.
")
```

**Output:** Critique at `docs/plans/[module-name]-critique.md`

### Step 3: Final Plan

After human reviews both draft and critique and makes decisions on open items:

1. Human documents decisions in `docs/plans/[module-name]-decisions.md`
2. Agent checks if `Docs/OpenCode/` exists; creates it only if missing
3. Agent generates final clean plan
4. Save to `Docs/OpenCode/M-[number].md` (final location for execution)

## Validation Gates

| Gate | Criteria | Pass Condition |
|------|----------|----------------|
| G0.1 | Requirements complete | All 5 items provided by human |
| G0.2 | Draft plan exists | File created with valid structure |
| G0.3 | Critique complete | Issues identified and addressed |
| G0.4 | Human decisions made | All open items resolved |
| G0.5 | Final plan ready | Clean plan at `Docs/OpenCode/M-[number].md` |
| G0.6 | No UI content | Zero references to WPF/XAML/Views/ViewModels in plan |

## Output

The final plan file at `Docs/OpenCode/M-[number].md` must contain:
- Module overview
- Slice breakdown (count determined by Planner, no min/max constraint)
- Per-slice: description, files, technical approach, dependencies, validation gate
- Dependency graph
- Risk assessment
- Edge cases
- Decisions log

**Must NOT contain:**
- Any WPF views, XAML, windows, or UserControls
- Any ViewModel references
- Any GUI-layer file paths
- Any DataTemplate or resource dictionary entries

## Anti-Hallucination Rules

1. Never assume requirements — ask if unclear
2. Never skip critique — every plan must be reviewed
3. Never finalize without human decisions — open items require approval
4. Never mix planning and execution — complete this skill before starting execution
5. Never write application source code — output is planning document only
6. Never include UI/GUI content — plan stops at Application layer boundary
7. Never enforce a slice-count minimum or maximum — use whatever count is functionally appropriate
8. Never recreate `Docs/OpenCode/` if it already exists

## Integration with Execution Skill

After this skill completes:
1. Final plan is at `Docs/OpenCode/M-[number].md`
2. Human invokes: `استخدم تقنية لوب إنجنيرنغ لتنفيذ M-[number].md`
3. The `module-execution` skill takes over
