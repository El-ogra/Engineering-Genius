---
name: loop-engineering
description: "DEPRECATED — This skill has been split into two independent skills. For PLANNING: use 'module-planning' skill (trigger: 'خطط لـ', 'ابدأ التخطيط', 'صمم خطة تنفيذ'). For EXECUTION: use 'module-execution' skill (trigger: 'نفّذ الخطة', 'execute plan', 'لوب إنجنيرنغ'). This file is kept for backward compatibility only."
license: MIT
compatibility: opencode
---

# Loop Engineering (Legacy Wrapper)

**This skill has been split into two independent skills:**

## For Planning → Use `module-planning` skill

- **Trigger:** "خطط لـ [module]", "ابدأ التخطيط", "صمم خطة تنفيذ"
- **Responsibility:** Produce an approved, reviewed action-plan file
- **Output:** `Docs/OpenCode/M-[number].md`
- **Does NOT write any application code**

## For Execution → Use `module-execution` skill

- **Trigger:** "استخدم تقنية لوب إنجنيرنغ لـ [filename].md", "use loop-engineering to execute [filename].md", "نفّذ الخطة [filename].md", "execute plan [filename].md"
- **Responsibility:** Generate a memory file + draft an execution prompt (does NOT execute slices itself)
- **Input:** An approved plan file
- **Output:** `Docs/OpenCode/M-XX-memory.md` + drafted prompt text

## Why the Split?

The original loop-engineering skill tried to do both planning and execution in one unit. This caused:
1. Confusion about when planning ends and execution begins
2. The orchestrator agent files (`.opencode/agents/*`) were never actually invokable by the Task tool
3. Planning and execution have different trigger phrases, different inputs, and different outputs

The two new skills are:
- **Independent:** Each can be invoked separately
- **Clear:** No ambiguity about what each does
- **Testable:** Each can be validated independently

## File Locations

```
.opencode/skills/
├── module-planning/          ← NEW: Planning skill
│   ├── SKILL.md
│   └── references/
│       ├── planning-workflow.md
│       └── plan-output-format.md
├── module-execution/         ← NEW: Execution skill
│   ├── SKILL.md
│   └── references/
│       ├── 10-stage-loop.md
│       ├── stop-conditions.md
│       ├── anti-patterns.md
│       ├── memory-file-template.md
│       └── execution-prompt.md
└── loop-engineering/         ← THIS FILE (legacy wrapper)
    ├── SKILL.md
    └── references/
```
