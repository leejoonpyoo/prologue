# Claude TaskSuperstar

A Claude Code skill for hierarchical PRD (Product Requirements Document) library management. Plan complex multi-phase projects before execution.

## What is this?

TaskSuperstar v2.0 is a **hierarchical PRD library** that manages project master plans and phase-based PRDs. Unlike Prometheus (which creates execution plans), TaskSuperstar organizes planning artifacts for future execution.

```
[Project Master Plan] → [Phase PRDs] → /prometheus → Execute
```

Part of the **Sisyphus Multi-Agent System**.

### Key Features

- **Project-Based Organization**: Master plan + phase PRDs
- **Incremental Phase Management**: Add phases as you go, not all upfront
- **Independent Work Units**: Each phase = one executable Prometheus task
- **Status Tracking**: planned → ready → in-progress → done
- **Prometheus Integration**: Ready phases feed directly into Prometheus
- **Inbox for Quick Ideas**: Capture standalone ideas outside projects

### Key Concept: Phases ≠ Maturity Levels

Phases are **independent work units**, not refinement stages:
- All phases have the same level of detail
- Phase numbers = execution order/priority
- Add phases incrementally as you plan

## Installation

### Option 1: Copy to Claude skills folder

```bash
git clone https://github.com/leejoonpyoo/claude-tasksuperstar.git
cp -r claude-tasksuperstar ~/.claude/skills/tasksuperstar
```

### Option 2: Symlink (recommended for development)

```bash
git clone https://github.com/leejoonpyoo/claude-tasksuperstar.git
ln -s $(pwd)/claude-tasksuperstar ~/.claude/skills/tasksuperstar
```

### Verify Installation

```bash
# In Claude Code
/tasksuperstar list
```

## Quick Start

### 1. Create a Project

```bash
/tasksuperstar new ba-platform
```

This creates:
- `.tasksuperstar/ba-platform/_master.md` (master plan)
- Updates `.tasksuperstar/index.md`

### 2. Add First Phase (when ready to detail it)

```bash
/tasksuperstar add ba-platform foundation
```

This creates:
- `.tasksuperstar/ba-platform/phase-01-foundation.md`

**Note**: Add phases incrementally. Don't plan all phases upfront.

### 3. Write Your PRDs

Edit the generated files with your planning details. Each phase PRD includes a "Prometheus Context" section for easy handoff.

### 4. Mark Phase Ready

```bash
/tasksuperstar status ba-platform foundation ready
```

### 5. Execute with Prometheus

```bash
/tasksuperstar run ba-platform foundation
# Displays the phase PRD
# Copy relevant parts for Prometheus

/prometheus
# Paste PRD context and let Prometheus create execution plan
```

### 6. Mark Complete

```bash
/tasksuperstar status ba-platform foundation done
```

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `new <project>` | Create project with master plan | `/tasksuperstar new ba-platform` |
| `add <project> <phase>` | Add phase to project | `/tasksuperstar add ba-platform auth` |
| `status <project> [phase] <status>` | Update status | `/tasksuperstar status ba-platform auth ready` |
| `run <project> <phase>` | Display phase for execution | `/tasksuperstar run ba-platform auth` |
| `inbox <name>` | Quick idea capture | `/tasksuperstar inbox mobile-app` |
| `list [project]` | List projects or phases | `/tasksuperstar list` |
| `show <project> [phase]` | Show details | `/tasksuperstar show ba-platform auth` |
| `archive <project>` | Archive completed project | `/tasksuperstar archive ba-platform` |
| `search <query>` | Search PRDs | `/tasksuperstar search authentication` |

## Folder Structure

```
.tasksuperstar/
├── {project-name}/
│   ├── _master.md              # Project master plan (vision, scope)
│   └── phase-XX-xxx.md         # Phases added incrementally
├── inbox/                      # Standalone ideas
├── archive/                    # Completed projects
└── index.md                    # Master index
```

## Status Flow

```
planned → ready → in-progress → done
```

- **planned**: Initial state, still being written
- **ready**: PRD complete, ready for Prometheus
- **in-progress**: Currently being executed
- **done**: Completed

Both projects and individual phases have status.

## Templates

### Master Plan

Each project has a master plan (`_master.md`) with:
- Vision and scope
- Phases table with status tracking
- Success criteria
- High-level notes

### Phase PRD

Each phase has its own PRD (`phase-XX-name.md`) with:
- Phase goal and scope
- Functional/non-functional requirements
- Technical approach
- Dependencies
- **Prometheus Context** section for easy handoff

### Inbox Ideas

Quick standalone ideas in `inbox/` with minimal structure:
- What: One sentence description
- Why: Why this matters
- Notes: Additional thoughts

## Integration with Sisyphus

TaskSuperstar sits at the beginning of the planning → execution pipeline:

```
TaskSuperstar (PRD Library)
    └── projects/{name}/_master.md + phase-XX.md
                              ↓
                    /tasksuperstar run
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

## Example: Incremental Project Development

```bash
# 1. Start project with master plan only
/tasksuperstar new ecommerce-platform
# → Edit _master.md: vision, overall scope, success criteria

# 2. Plan and execute first phase
/tasksuperstar add ecommerce-platform user-auth
# → Edit phase-01-user-auth.md with detailed requirements
/tasksuperstar status ecommerce-platform user-auth ready
/tasksuperstar run ecommerce-platform user-auth
/prometheus  # Execute

# 3. Complete first phase, add next
/tasksuperstar status ecommerce-platform user-auth done
/tasksuperstar add ecommerce-platform product-catalog
# → Edit phase-02-product-catalog.md
# → Repeat cycle...
```

**Why incremental?** Requirements evolve. Earlier phases inform later ones. Plan each phase when you're ready to execute it.

## Example: Quick Idea Capture

```bash
# Capture a quick idea
/tasksuperstar inbox real-time-notifications

# Later, promote to full project
/tasksuperstar new real-time-notifications
/tasksuperstar add real-time-notifications websocket-server
/tasksuperstar add real-time-notifications client-library
```

## Best Practices

1. **One project per major initiative**: Keep related work together
2. **Phases = executable chunks**: Each phase should be independently executable with Prometheus
3. **Write Prometheus Context**: Include a dedicated section for easy handoff
4. **Use inbox liberally**: Capture ideas fast, organize later
5. **Number phases logically**: 01, 02, 03... shows execution order
6. **Update master plan**: Keep the phases table in sync
7. **Archive when done**: Clean active view, preserve history

## Comparison: v1 vs v2

| Aspect | v1.0 | v2.0 |
|--------|------|------|
| Structure | Flat (ideas/drafts/ready) | Hierarchical (projects/phases) |
| Use Case | Individual PRDs | Multi-phase projects |
| Master Plan | None | Per-project _master.md |
| Phases | No concept | Core feature with ordering |
| Progression | idea → draft → ready | planned → ready → in-progress → done |
| Best For | Small standalone ideas | Large complex projects |

**When to use each:**
- Use v2.0 (current) for multi-phase projects
- v1.0 pattern (inbox) still available for quick standalone ideas

## Requirements

- Claude Code CLI
- (Optional) Prometheus agent for execution planning
- (Optional) planning-with-files skill for execution context

## Troubleshooting

### Commands not recognized
Ensure the skill is in `~/.claude/skills/tasksuperstar/` and `SKILL.md` is present.

### Index not updating
The index is auto-generated. If it's stale, check the hooks in SKILL.md are configured.

### Phase numbering issues
Phase numbers are auto-assigned based on creation order. Use leading zeros: `01`, `02`, etc.

## Related Projects

- [claude-task-planning](https://github.com/leejoonpyoo/claude-task-planning) - Execution context management
- [Sisyphus Multi-Agent System](https://github.com/leejoonpyoo/sisyphus) - Full orchestration system
- [Prometheus Agent](https://github.com/leejoonpyoo/prometheus) - Strategic planning agent

## License

MIT License

## Contributing

Contributions welcome! Please open issues or PRs on GitHub.

## Changelog

### v2.0.0 (2026-01-27)
- Complete rewrite to hierarchical project/phase structure
- Added master plan concept
- Removed flat ideas/drafts/ready structure
- Added project-level and phase-level status
- Added inbox for quick standalone ideas
- Enhanced Prometheus integration with context sections

### v1.0.0 (2026-01-20)
- Initial release with flat PRD library structure
