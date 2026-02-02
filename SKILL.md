# Prologue Skill

name: prologue
description: PRD library and brainstorming storage - save ideas before execution
version: 3.0.0
author: leejoonpyoo

## Overview

Prologue is a **hierarchical PRD (Product Requirements Document) library** for planning before execution. It manages project master plans and chapter-based PRDs that feed into Prometheus for implementation.

```
[Project Master Plan] → [Chapter PRDs] → /prometheus → Execute
```

## When to Use

- Planning large projects with multiple chapters
- Breaking down complex work into executable chunks
- Building a library of project plans
- Preparing PRDs before Prometheus execution
- Storing standalone ideas for future reference

## Commands

| Command | Description |
|---------|-------------|
| `/prologue new <project>` | Create new project with master plan |
| `/prologue add <project> <chapter>` | Add chapter PRD to project |
| `/prologue status <project> [chapter] <status>` | Change status (planned/ready/in-progress/done) |
| `/prologue run <project> <chapter>` | Prepare chapter for Prometheus |
| `/prologue inbox <name>` | Quick standalone idea |
| `/prologue list [project]` | List projects or chapters |
| `/prologue show <project> [chapter]` | Show details |
| `/prologue archive <project>` | Archive completed project |
| `/prologue search <query>` | Search all PRDs |

## Key Concept: Chapters

**Chapters are independent work units, NOT refinement stages.**

- All chapters have the same level of detail (fully executable PRDs)
- Chapter numbers indicate execution order/priority, not maturity
- Each chapter = one Prometheus run
- Add chapters incrementally as you plan, not all upfront

```
_master.md (전체 비전)
    ├── chapter-01 (작업1) ─→ /prometheus ─→ 실행
    ├── chapter-02 (작업2) ─→ /prometheus ─→ 실행
    └── chapter-03 (작업3) ─→ /prometheus ─→ 실행
```

## Folder Structure

```
.prologue/
├── _inbox/                     # Standalone ideas (system folder)
├── _archive/                   # Completed projects (system folder)
├── {project-name}/
│   ├── _master.md              # Project master plan (vision, scope)
│   └── chapter-01-xxx.md       # Add chapters as needed
└── index.md                    # Master index
```

## Status Flow

```
planned → ready → in-progress → done
                       ↓
                  /prometheus
```

- **planned**: Initial state, still being written
- **ready**: PRD complete, ready for Prometheus
- **in-progress**: Currently being executed
- **done**: Completed

## Templates

### Master Plan (_master.md)

```markdown
# Project: {name}
**Created:** {timestamp}
**Status:** planned

## Vision

[What is this project trying to achieve?]

## Scope

### In Scope
- Major deliverable 1
- Major deliverable 2

### Out of Scope
- What this project will NOT do

## Chapters

| Chapter | Name | Status | Description |
|---------|------|--------|-------------|
| 01 | foundation | planned | [Brief description] |
| 02 | core-engine | planned | [Brief description] |
| 03 | api-layer | planned | [Brief description] |

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

## Notes

-
```

### Chapter PRD (chapter-XX-xxx.md)

```markdown
# Chapter: {name}
**Project:** {project-name}
**Chapter:** {XX}
**Status:** planned

## Goal

[What does this chapter accomplish?]

## Scope

[What's included in THIS chapter specifically]

## Requirements

### Functional
- [ ] FR1: Description
- [ ] FR2: Description

### Non-Functional
- [ ] NFR1: Performance/security requirement
- [ ] NFR2: Other requirement

## Technical Approach

[How will this be implemented?]

## Dependencies

- Depends on: [Previous chapters or external dependencies]
- Enables: [What this chapter unlocks]

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Prometheus Context

[When ready to execute, this section provides context for /prometheus]

**Background:** [Brief project context]
**This Chapter:** [What to build in this chapter]
**Constraints:** [Important limitations or requirements]

## Notes

-
```

### Inbox (inbox/*.md)

```markdown
# Idea: {name}
**Created:** {timestamp}

## What

[One sentence description]

## Why

[Why this matters]

## Notes

-
```

## Workflow Example

```bash
# 1. Create project (starts with _master.md only)
/prologue new ba-platform
# → Edit _master.md with vision, scope, success criteria

# 2. Add first chapter when ready to plan it
/prologue add ba-platform foundation
# → Edit chapter-01-foundation.md with detailed requirements

# 3. Mark ready and execute
/prologue status ba-platform foundation ready
/prologue run ba-platform foundation
/prometheus  # Execute with Prometheus

# 4. Complete and add next chapter
/prologue status ba-platform foundation done
/prologue add ba-platform core-engine  # Add next chapter when needed
# → Repeat cycle
```

**Incremental approach**: Don't plan all chapters upfront. Add each chapter as the previous one completes or when you're ready to detail it.

## Integration with Sisyphus

```
Prologue (PRD Library)
    └── projects/{name}/_master.md + chapter-XX.md
                              ↓
                    /prologue run
                              ↓
Prometheus (Strategic Planning)
    └── .sisyphus/plans/{task}.md
                              ↓
Sisyphus Agents (Execution)
                              ↓
Archive
```

## Best Practices

1. **One project per major initiative**: Don't mix unrelated work
2. **Chapters should be independently executable**: Each chapter = one Prometheus run
3. **Write Prometheus Context section**: Makes handoff seamless
4. **Use inbox for quick captures**: Promote to project when ready to plan
5. **Archive when done**: Keep history, clean active view
6. **Number chapters logically**: 01, 02, 03... to show execution order
7. **Update master plan chapters table**: Keep status in sync

## Comparison: v2 vs v3

| Aspect | v2.0 | v3.0 |
|--------|------|------|
| Name | TaskSuperstar | Prologue |
| Work Units | Phases | Chapters |
| Folder | .tasksuperstar/ | .prologue/ |
| Command | /tasksuperstar | /prologue |
| Philosophy | Same | Same (improved naming) |

## Status Management

### Project Status
- **planned**: Some chapters still being written
- **ready**: All chapters ready for execution
- **in-progress**: Currently executing
- **done**: All chapters complete

### Chapter Status
- **planned**: PRD being written
- **ready**: PRD complete, ready for Prometheus
- **in-progress**: Being executed
- **done**: Completed

Change status with:
```bash
/prologue status <project> <status>        # Project-level
/prologue status <project> <chapter> <status> # Chapter-level
```

hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "cat .prologue/index.md 2>/dev/null | head -30 || true"
