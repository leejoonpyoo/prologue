# prd-manager Skill

name: prd-manager
description: When a complex project idea needs to be broken down into independently executable PRD chapters before handing off to OMC for execution
version: 4.0.0
author: leejoonpyoo

## Overview

prd-manager is a **hierarchical PRD library** for decomposing complex projects into independently executable chapters. Each chapter is a self-contained PRD that can be handed off to OMC (autopilot / ralph / team) for execution.

```
[Project Master Plan] → [Chapter PRDs] → /oh-my-claudecode:plan → Execute
```

## When to Use

- A complex project idea needs to be broken down before execution
- Managing multiple PRD chapters across a large initiative
- Building a library of project plans with status tracking
- Capturing standalone ideas for future planning

## Commands

| Command | Description |
|---------|-------------|
| `/prd-manager new <project>` | Create new project with master plan |
| `/prd-manager add <project> <chapter>` | Add chapter PRD to project |
| `/prd-manager status <project> [chapter] <status>` | Change status (planned/ready/in-progress/done) |
| `/prd-manager run <project> <chapter>` | Prepare chapter for Prometheus |
| `/prd-manager inbox <name>` | Quick standalone idea |
| `/prd-manager list [project]` | List projects or chapters |
| `/prd-manager show <project> [chapter]` | Show details |
| `/prd-manager archive <project>` | Archive completed project |
| `/prd-manager search <query>` | Search all PRDs |

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

## Project Naming: YYMMDD-NN Format

Projects are automatically organized with date-based naming:
- Format: `YYMMDD-NN_project-name` (e.g., `260202-01_ba-platform`)
- Sorted chronologically, same-day projects get sequential index
- Reference projects by name only (e.g., `/prd-manager add ba-platform chapter`)

## Folder Structure

```
.prologue/
├── _inbox/                          # Standalone ideas
├── _archive/                        # Completed projects
├── YYMMDD-NN_project-name/          # Date-indexed projects
│   ├── _master.md                   # Project master plan
│   └── chapter-XX-xxx.md            # Chapters
└── index.md                         # Master index
```

## Status Flow

```
planned → ready → in-progress → done
                       ↓
             /oh-my-claudecode:plan
             → autopilot / ralph / team
```

- **planned**: Initial state, still being written
- **ready**: PRD complete, ready for execution
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

## Execution Context

[When ready to execute, this section provides context for autopilot/ralph]

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
/prd-manager new ba-platform
# → Edit _master.md with vision, scope, success criteria

# 2. Add first chapter when ready to plan it
/prd-manager add ba-platform foundation
# → Edit chapter-01-foundation.md with detailed requirements

# 3. Mark ready and execute
/prd-manager status ba-platform foundation ready
/prd-manager run ba-platform foundation
/oh-my-claudecode:autopilot  # or ralph / team

# 4. Complete and add next chapter
/prd-manager status ba-platform foundation done
/prd-manager add ba-platform core-engine  # Add next chapter when needed
# → Repeat cycle
```

**Incremental approach**: Don't plan all chapters upfront. Add each chapter as the previous one completes or when you're ready to detail it.

## Integration with OMC

```
prd-manager (PRD Library)
    └── _master.md + chapter-XX.md
                  ↓
        /prd-manager run
                  ↓
OMC Planning (/oh-my-claudecode:plan)
    └── .omc/plans/
                  ↓
OMC Execution (autopilot / ralph / team)
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
| Name | TaskSuperstar | prd-manager |
| Work Units | Phases | Chapters |
| Folder | .tasksuperstar/ | .prologue/ |
| Command | /tasksuperstar | /prd-manager |
| Philosophy | Same | Same (improved naming) |

## Status Management

### Project Status
- **planned**: Some chapters still being written
- **ready**: All chapters ready for execution
- **in-progress**: Currently executing
- **done**: All chapters complete

### Chapter Status
- **planned**: PRD being written
- **ready**: PRD complete, ready for execution
- **in-progress**: Being executed
- **done**: Completed

Change status with:
```bash
/prd-manager status <project> <status>        # Project-level
/prd-manager status <project> <chapter> <status> # Chapter-level
```

