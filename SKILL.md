# TaskSuperstar Skill

name: tasksuperstar
description: PRD library and brainstorming storage - save ideas before execution
version: 2.0.0
author: leejoonpyoo

## Overview

TaskSuperstar is a **hierarchical PRD (Product Requirements Document) library** for planning before execution. It manages project master plans and phase-based PRDs that feed into Prometheus for implementation.

```
[Project Master Plan] → [Phase PRDs] → /prometheus → Execute
```

## When to Use

- Planning large projects with multiple phases
- Breaking down complex work into executable chunks
- Building a library of project plans
- Preparing PRDs before Prometheus execution
- Storing standalone ideas for future reference

## Commands

| Command | Description |
|---------|-------------|
| `/tasksuperstar new <project>` | Create new project with master plan |
| `/tasksuperstar add <project> <phase>` | Add phase PRD to project |
| `/tasksuperstar status <project> [phase] <status>` | Change status (planned/ready/in-progress/done) |
| `/tasksuperstar run <project> <phase>` | Prepare phase for Prometheus |
| `/tasksuperstar inbox <name>` | Quick standalone idea |
| `/tasksuperstar list [project]` | List projects or phases |
| `/tasksuperstar show <project> [phase]` | Show details |
| `/tasksuperstar archive <project>` | Archive completed project |
| `/tasksuperstar search <query>` | Search all PRDs |

## Folder Structure

```
.tasksuperstar/
├── {project-name}/
│   ├── _master.md              # Project master plan
│   ├── phase-01-foundation.md  # Phase 1 PRD
│   ├── phase-02-core.md        # Phase 2 PRD
│   └── phase-03-api.md         # Phase 3 PRD
├── inbox/                      # Standalone ideas
│   └── some-idea.md
├── archive/                    # Completed projects
│   └── YYYY-MM-DD_{project}/
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

## Phases

| Phase | Name | Status | Description |
|-------|------|--------|-------------|
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

### Phase PRD (phase-XX-xxx.md)

```markdown
# Phase: {name}
**Project:** {project-name}
**Phase:** {XX}
**Status:** planned

## Goal

[What does this phase accomplish?]

## Scope

[What's included in THIS phase specifically]

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

- Depends on: [Previous phases or external dependencies]
- Enables: [What this phase unlocks]

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Prometheus Context

[When ready to execute, this section provides context for /prometheus]

**Background:** [Brief project context]
**This Phase:** [What to build in this phase]
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
# 1. Create project
/tasksuperstar new ba-platform

# 2. Add phases
/tasksuperstar add ba-platform foundation
/tasksuperstar add ba-platform core-engine
/tasksuperstar add ba-platform api-layer

# 3. Write PRDs (edit the files)
# Edit .tasksuperstar/ba-platform/_master.md
# Edit .tasksuperstar/ba-platform/phase-01-foundation.md

# 4. Mark ready when complete
/tasksuperstar status ba-platform foundation ready

# 5. Execute with Prometheus
/tasksuperstar run ba-platform foundation
# This displays the phase PRD for easy copy/paste to /prometheus

/prometheus
# Use the PRD content

# 6. Mark done when complete
/tasksuperstar status ba-platform foundation done
```

## Integration with Sisyphus

```
TaskSuperstar (PRD Library)
    └── projects/{name}/_master.md + phase-XX.md
                              ↓
                    /tasksuperstar run
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
2. **Phases should be independently executable**: Each phase = one Prometheus run
3. **Write Prometheus Context section**: Makes handoff seamless
4. **Use inbox for quick captures**: Promote to project when ready to plan
5. **Archive when done**: Keep history, clean active view
6. **Number phases logically**: 01, 02, 03... to show execution order
7. **Update master plan phases table**: Keep status in sync

## Comparison: v1 vs v2

| Aspect | v1.0 | v2.0 |
|--------|------|------|
| Structure | Flat (ideas/drafts/ready) | Hierarchical (projects/phases) |
| Use Case | Individual PRDs | Multi-phase projects |
| Progression | idea → draft → ready | planned → ready → in-progress → done |
| Master Plan | None | Per-project _master.md |
| Phases | No concept | Core feature |
| Best For | Small standalone ideas | Large complex projects |

## Status Management

### Project Status
- **planned**: Some phases still being written
- **ready**: All phases ready for execution
- **in-progress**: Currently executing
- **done**: All phases complete

### Phase Status
- **planned**: PRD being written
- **ready**: PRD complete, ready for Prometheus
- **in-progress**: Being executed
- **done**: Completed

Change status with:
```bash
/tasksuperstar status <project> <status>        # Project-level
/tasksuperstar status <project> <phase> <status> # Phase-level
```

hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "cat .tasksuperstar/index.md 2>/dev/null | head -30 || true"
