# Prologue

A Claude Code skill for hierarchical PRD (Product Requirements Document) library management. Plan complex multi-chapter projects before execution.

## What is this?

Prologue v3.0 is a **hierarchical PRD library** that manages project master plans and chapter-based PRDs. Unlike Prometheus (which creates execution plans), Prologue organizes planning artifacts for future execution.

```
[Project Master Plan] → [Chapter PRDs] → /prometheus → Execute
```

Part of the **Sisyphus Multi-Agent System**.

### Key Features

- **Project-Based Organization**: Master plan + chapter PRDs
- **Incremental Chapter Management**: Add chapters as you go, not all upfront
- **Independent Work Units**: Each chapter = one executable Prometheus task
- **Status Tracking**: planned → ready → in-progress → done
- **Prometheus Integration**: Ready chapters feed directly into Prometheus
- **Inbox for Quick Ideas**: Capture standalone ideas outside projects

### Key Concept: Chapters ≠ Maturity Levels

Chapters are **independent work units**, not refinement stages:
- All chapters have the same level of detail
- Chapter numbers = execution order/priority
- Add chapters incrementally as you plan

### Project Naming: YYMMDD-NN Format

Projects are automatically organized with date-based naming:
- Format: `YYMMDD-NN_project-name` (e.g., `260202-01_ba-platform`)
- Sorted chronologically by default
- Same-day projects get sequential index (01, 02, 03...)
- Reference projects by name only: `/prologue add ba-platform chapter`

## Installation

### Option 1: Copy to Claude skills folder

```bash
git clone https://github.com/leejoonpyoo/prologue.git
cp -r prologue ~/.claude/skills/prologue
```

### Option 2: Symlink (recommended for development)

```bash
git clone https://github.com/leejoonpyoo/prologue.git
ln -s $(pwd)/prologue ~/.claude/skills/prologue
```

### Verify Installation

```bash
# In Claude Code
/prologue list
```

## Quick Start

### 1. Create a Project

```bash
/prologue new ba-platform
```

This creates:
- `.prologue/260202-01_ba-platform/_master.md` (with date-indexed folder)
- Updates `.prologue/index.md`

### 2. Add First Chapter (when ready to detail it)

```bash
/prologue add ba-platform foundation
```

This creates:
- `.prologue/260202-01_ba-platform/chapter-01-foundation.md`

**Note**: Reference projects by name (e.g., `ba-platform`), the system finds the full folder automatically.

**Note**: Add chapters incrementally. Don't plan all chapters upfront.

### 3. Write Your PRDs

Edit the generated files with your planning details. Each chapter PRD includes a "Prometheus Context" section for easy handoff.

### 4. Mark Chapter Ready

```bash
/prologue status ba-platform foundation ready
```

### 5. Execute with Prometheus

```bash
/prologue run ba-platform foundation
# Displays the chapter PRD
# Copy relevant parts for Prometheus

/prometheus
# Paste PRD context and let Prometheus create execution plan
```

### 6. Mark Complete

```bash
/prologue status ba-platform foundation done
```

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `new <project>` | Create project with master plan | `/prologue new ba-platform` |
| `add <project> <chapter>` | Add chapter to project | `/prologue add ba-platform auth` |
| `status <project> [chapter] <status>` | Update status | `/prologue status ba-platform auth ready` |
| `run <project> <chapter>` | Display chapter for execution | `/prologue run ba-platform auth` |
| `inbox <name>` | Quick idea capture | `/prologue inbox mobile-app` |
| `list [project]` | List projects or chapters | `/prologue list` |
| `show <project> [chapter]` | Show details | `/prologue show ba-platform auth` |
| `archive <project>` | Archive completed project | `/prologue archive ba-platform` |
| `search <query>` | Search PRDs | `/prologue search authentication` |

## Folder Structure

```
.prologue/
├── _inbox/                          # Standalone ideas (system folder)
├── _archive/                        # Completed projects (system folder)
├── YYMMDD-NN_project-name/          # Date-indexed project folders
│   ├── _master.md                   # Project master plan (vision, scope)
│   └── chapter-XX-xxx.md            # Chapters added incrementally
└── index.md                         # Master index
```

Example:
```
.prologue/
├── 260202-01_ba-platform/
│   ├── _master.md
│   ├── chapter-01-foundation.md
│   └── chapter-02-api.md
├── 260202-02_mobile-app/
│   └── _master.md
└── index.md
```

## Status Flow

```
planned → ready → in-progress → done
```

- **planned**: Initial state, still being written
- **ready**: PRD complete, ready for Prometheus
- **in-progress**: Currently being executed
- **done**: Completed

Both projects and individual chapters have status.

## Templates

### Master Plan

Each project has a master plan (`_master.md`) with:
- Vision and scope
- Chapters table with status tracking
- Success criteria
- High-level notes

### Chapter PRD

Each chapter has its own PRD (`chapter-XX-name.md`) with:
- Chapter goal and scope
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

Prologue sits at the beginning of the planning → execution pipeline:

```
Prologue (PRD Library)
    └── projects/{name}/_master.md + chapter-XX.md
                              ↓
                    /prologue run
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
/prologue new ecommerce-platform
# → Edit _master.md: vision, overall scope, success criteria

# 2. Plan and execute first chapter
/prologue add ecommerce-platform user-auth
# → Edit chapter-01-user-auth.md with detailed requirements
/prologue status ecommerce-platform user-auth ready
/prologue run ecommerce-platform user-auth
/prometheus  # Execute

# 3. Complete first chapter, add next
/prologue status ecommerce-platform user-auth done
/prologue add ecommerce-platform product-catalog
# → Edit chapter-02-product-catalog.md
# → Repeat cycle...
```

**Why incremental?** Requirements evolve. Earlier chapters inform later ones. Plan each chapter when you're ready to execute it.

## Example: Quick Idea Capture

```bash
# Capture a quick idea
/prologue inbox real-time-notifications

# Later, promote to full project
/prologue new real-time-notifications
/prologue add real-time-notifications websocket-server
/prologue add real-time-notifications client-library
```

## Best Practices

1. **One project per major initiative**: Keep related work together
2. **Chapters = executable chunks**: Each chapter should be independently executable with Prometheus
3. **Write Prometheus Context**: Include a dedicated section for easy handoff
4. **Use inbox liberally**: Capture ideas fast, organize later
5. **Number chapters logically**: 01, 02, 03... shows execution order
6. **Update master plan**: Keep the chapters table in sync
7. **Archive when done**: Clean active view, preserve history

## Migration

### From TaskSuperstar v2 or older Prologue

```bash
/prologue migrate
```

The migrate script will:
- Convert `.tasksuperstar/` → `.prologue/` (if applicable)
- Rename `phase-XX-*.md` → `chapter-XX-*.md`
- Convert `project-name/` → `YYMMDD-NN_project-name/` (uses created date from _master.md)

## Comparison: v2 vs v3

| Aspect | v2.0 (TaskSuperstar) | v3.0 (Prologue) |
|--------|----------------------|-----------------|
| Name | TaskSuperstar | Prologue |
| Work Units | Phases | Chapters |
| Folder | .tasksuperstar/ | .prologue/ |
| Command | /tasksuperstar | /prologue |
| Philosophy | Hierarchical PRD | Same (improved naming) |

**Why the change?** "Prologue + Chapter" creates a cohesive literary metaphor: you write the prologue (master plan) and chapters (work units) of your project's story before executing it.

## Requirements

- Claude Code CLI
- (Optional) Prometheus agent for execution planning
- (Optional) planning-with-files skill for execution context

## Troubleshooting

### Commands not recognized
Ensure the skill is in `~/.claude/skills/prologue/` and `SKILL.md` is present.

### Index not updating
The index is auto-generated. If it's stale, check the hooks in SKILL.md are configured.

### Chapter numbering issues
Chapter numbers are auto-assigned based on creation order. Use leading zeros: `01`, `02`, etc.

## Related Projects

- [claude-task-planning](https://github.com/leejoonpyoo/claude-task-planning) - Execution context management
- [Sisyphus Multi-Agent System](https://github.com/leejoonpyoo/sisyphus) - Full orchestration system
- [Prometheus Agent](https://github.com/leejoonpyoo/prometheus) - Strategic planning agent

## License

MIT License

## Contributing

Contributions welcome! Please open issues or PRs on GitHub.

## Changelog

### v3.1.0 (2026-02-02)
- Added date-indexed project naming: `YYMMDD-NN_project-name`
- Projects sorted chronologically by default
- Same-day projects get sequential index
- Reference projects by name only (auto-lookup)
- Migration script updates existing projects to new format

### v3.0.0 (2026-02-02)
- Renamed from TaskSuperstar to Prologue
- Changed "phase" terminology to "chapter"
- Updated folder from .tasksuperstar/ to .prologue/
- Improved literary metaphor: Prologue + Chapters

### v2.0.0 (2026-01-27)
- Complete rewrite to hierarchical project/phase structure
- Added master plan concept
- Removed flat ideas/drafts/ready structure
- Added project-level and phase-level status
- Added inbox for quick standalone ideas
- Enhanced Prometheus integration with context sections

### v1.0.0 (2026-01-20)
- Initial release with flat PRD library structure
