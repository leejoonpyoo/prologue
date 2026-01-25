# TaskSuperstar Skill

name: tasksuperstar
description: PRD library and brainstorming storage - save ideas before execution
version: 1.0.0
author: leejoonpyoo

## Overview

TaskSuperstar is a **lightweight PRD (Product Requirements Document) library** for brainstorming and storing ideas before execution. Unlike Prometheus (which plans for immediate execution), TaskSuperstar stores ideas for future reference.

```
Idea → Draft → Ready → (later) /prometheus → Execute
```

## When to Use

- Brainstorming ideas you want to save for later
- Writing PRDs before you're ready to execute
- Building a library of potential features/projects
- Organizing ideas by category/priority
- When you want to "think" but not "do"

## Commands

| Command | Description |
|---------|-------------|
| `/tasksuperstar idea <name>` | Create new idea (minimal) |
| `/tasksuperstar draft <name>` | Create draft PRD (structured) |
| `/tasksuperstar promote <name>` | Promote idea→draft or draft→ready |
| `/tasksuperstar list [status]` | List all PRDs (ideas/drafts/ready) |
| `/tasksuperstar show <name>` | Show PRD details |
| `/tasksuperstar archive <name>` | Archive completed/abandoned PRD |
| `/tasksuperstar search <query>` | Search PRDs by content |

## Folder Structure

```
.tasksuperstar/
├── ideas/              # Quick ideas, minimal structure
│   └── {name}.md
├── drafts/             # Work-in-progress PRDs
│   └── {name}.md
├── ready/              # Complete PRDs, ready for execution
│   └── {name}.md
├── archive/            # Completed or abandoned
│   └── YYYY-MM-DD_{name}.md
└── index.md            # Master index of all PRDs
```

## Templates

### Idea (Minimal)
```markdown
# Idea: {name}
**Created:** {timestamp}
**Status:** idea

## What
[One sentence description]

## Why
[Why this matters]

## Notes
-
```

### Draft (Structured)
```markdown
# Draft: {name}
**Created:** {timestamp}
**Status:** draft
**Priority:** low/medium/high
**Category:** [feature/improvement/bug/research]

## Problem
[What problem does this solve?]

## Proposed Solution
[High-level approach]

## Requirements
- [ ] Requirement 1
- [ ] Requirement 2

## Open Questions
- [ ] Question 1

## Notes
-
```

### Ready (Full PRD)
```markdown
# PRD: {name}
**Created:** {timestamp}
**Status:** ready
**Priority:** high
**Category:** [feature/improvement/bug/research]
**Estimated Effort:** [small/medium/large]

## Problem Statement
[Detailed problem description]

## Goals
- Goal 1
- Goal 2

## Non-Goals
- What this will NOT do

## Proposed Solution
[Detailed solution]

## Requirements
### Functional
- [ ] FR1: Description
- [ ] FR2: Description

### Non-Functional
- [ ] NFR1: Performance requirement
- [ ] NFR2: Security requirement

## Technical Approach
[Implementation details]

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
|      |            |

## Success Metrics
- Metric 1
- Metric 2

## Timeline
- Phase 1: Description
- Phase 2: Description

## Open Questions
- [ ] Resolved questions go here

## References
-
```

## Workflow

### Creating Ideas
```bash
/tasksuperstar idea mobile-app
# Creates .tasksuperstar/ideas/mobile-app.md
```

### Promoting to Draft
```bash
/tasksuperstar promote mobile-app
# Moves to .tasksuperstar/drafts/mobile-app.md
# Expands template with more structure
```

### Promoting to Ready
```bash
/tasksuperstar promote mobile-app
# Moves to .tasksuperstar/ready/mobile-app.md
# Full PRD template
```

### Executing (with Prometheus)
```bash
/prometheus mobile-app
# Reads .tasksuperstar/ready/mobile-app.md as input
# Creates execution plan in .sisyphus/plans/
```

## Integration with Sisyphus

TaskSuperstar sits **before** the Sisyphus execution pipeline:

```
TaskSuperstar (Planning Library)
    └── ideas/ → drafts/ → ready/
                              ↓
Prometheus (Strategic Planning)
    └── .sisyphus/plans/{task}.md
                              ↓
planning-with-files (Execution Context)
    └── .sisyphus/active/{task}/
                              ↓
Sisyphus Agents (Execution)
                              ↓
Archive
    └── .sisyphus/archive/YYYY-MM-DD_{task}/
```

## Best Practices

1. **Capture immediately**: When you have an idea, create it instantly
2. **Don't over-polish ideas**: Ideas are meant to be rough
3. **Promote when ready**: Move to draft only when you want to think more deeply
4. **Ready means ready**: Only promote to ready when you could execute tomorrow
5. **Archive freely**: Don't delete - archive for future reference

## Index Management

The `index.md` file automatically tracks all PRDs:

```markdown
# TaskSuperstar Index

## Ideas (3)
- [ ] mobile-app - "Mobile companion app"
- [ ] dark-mode - "Add dark mode support"
- [ ] api-v2 - "API version 2 redesign"

## Drafts (2)
- [ ] auth-system - "OAuth2 authentication"
- [ ] caching - "Redis caching layer"

## Ready (1)
- [ ] dashboard - "Admin dashboard redesign"

## Recently Archived
- [x] 2026-01-20_old-feature - completed
```

hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "cat .tasksuperstar/index.md 2>/dev/null | head -20 || true"
