# prd-manager

A Claude Code skill for hierarchical PRD (Product Requirements Document) library management. Plan complex multi-chapter projects before execution.

## What is this?

prd-manager v3.0 is a **hierarchical PRD library** that manages project master plans and chapter-based PRDs. prd-manager organizes planning artifacts before handing off to OMC for execution.

```
[Project Master Plan] → [Chapter PRDs] → /oh-my-claudecode:plan → Execute
```

### Key Features

- **Project-Based Organization**: Master plan + chapter PRDs
- **Incremental Chapter Management**: Add chapters as you go, not all upfront
- **Independent Work Units**: Each chapter = one executable OMC task
- **Status Tracking**: planned → ready → in-progress → done
- **OMC Integration**: Ready chapters feed directly into autopilot/ralph/team
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
- Reference projects by name only: `/prd-manager add ba-platform chapter`

## Installation

### Option 1: Copy to Claude skills folder

```bash
git clone https://github.com/leejoonpyoo/prd-manager.git
cp -r prologue ~/.claude/skills/prd-manager
```

### Option 2: Symlink (recommended for development)

```bash
git clone https://github.com/leejoonpyoo/prd-manager.git
ln -s $(pwd)/prd-manager ~/.claude/skills/prd-manager
```

### Verify Installation

```bash
# In Claude Code
/prd-manager list
```

## Quick Start

### 1. Create a Project

```bash
/prd-manager new ba-platform
```

This creates:
- `.prologue/260202-01_ba-platform/_master.md` (with date-indexed folder)
- Updates `.prologue/index.md`

### 2. Add First Chapter (when ready to detail it)

```bash
/prd-manager add ba-platform foundation
```

This creates:
- `.prologue/260202-01_ba-platform/chapter-01-foundation.md`

**Note**: Reference projects by name (e.g., `ba-platform`), the system finds the full folder automatically.

**Note**: Add chapters incrementally. Don't plan all chapters upfront.

### 3. Write Your PRDs

Edit the generated files with your planning details. Each chapter PRD includes an "Execution Context" section for easy handoff.

### 4. Mark Chapter Ready

```bash
/prd-manager status ba-platform foundation ready
```

### 5. Execute with OMC

```bash
/prd-manager run ba-platform foundation
# Displays the chapter PRD

/oh-my-claudecode:autopilot  # or ralph / team
# Paste Execution Context and let OMC execute
```

### 6. Mark Complete

```bash
/prd-manager status ba-platform foundation done
```

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `new <project>` | Create project with master plan | `/prd-manager new ba-platform` |
| `add <project> <chapter>` | Add chapter to project | `/prd-manager add ba-platform auth` |
| `status <project> [chapter] <status>` | Update status | `/prd-manager status ba-platform auth ready` |
| `run <project> <chapter>` | Display chapter for execution | `/prd-manager run ba-platform auth` |
| `inbox <name>` | Quick idea capture | `/prd-manager inbox mobile-app` |
| `list [project]` | List projects or chapters | `/prd-manager list` |
| `show <project> [chapter]` | Show details | `/prd-manager show ba-platform auth` |
| `archive <project>` | Archive completed project | `/prd-manager archive ba-platform` |
| `search <query>` | Search PRDs | `/prd-manager search authentication` |

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
- **ready**: PRD complete, ready for execution
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
- **Execution Context** section for easy handoff

### Inbox Ideas

Quick standalone ideas in `inbox/` with minimal structure:
- What: One sentence description
- Why: Why this matters
- Notes: Additional thoughts

## Integration with OMC

prd-manager sits at the beginning of the planning → execution pipeline:

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

## Example: Incremental Project Development

```bash
# 1. Start project with master plan only
/prd-manager new ecommerce-platform
# → Edit _master.md: vision, overall scope, success criteria

# 2. Plan and execute first chapter
/prd-manager add ecommerce-platform user-auth
# → Edit chapter-01-user-auth.md with detailed requirements
/prd-manager status ecommerce-platform user-auth ready
/prd-manager run ecommerce-platform user-auth
/oh-my-claudecode:autopilot  # or ralph / team

# 3. Complete first chapter, add next
/prd-manager status ecommerce-platform user-auth done
/prd-manager add ecommerce-platform product-catalog
# → Edit chapter-02-product-catalog.md
# → Repeat cycle...
```

**Why incremental?** Requirements evolve. Earlier chapters inform later ones. Plan each chapter when you're ready to execute it.

## Example: Quick Idea Capture

```bash
# Capture a quick idea
/prd-manager inbox real-time-notifications

# Later, promote to full project
/prd-manager new real-time-notifications
/prd-manager add real-time-notifications websocket-server
/prd-manager add real-time-notifications client-library
```

## Best Practices

1. **One project per major initiative**: Keep related work together
2. **Chapters = executable chunks**: Each chapter should be independently executable with OMC
3. **Write Execution Context**: Include a dedicated section for easy handoff
4. **Use inbox liberally**: Capture ideas fast, organize later
5. **Number chapters logically**: 01, 02, 03... shows execution order
6. **Update master plan**: Keep the chapters table in sync
7. **Archive when done**: Clean active view, preserve history

## Requirements

- Claude Code CLI
- (Optional) oh-my-claudecode plugin for OMC execution

## Troubleshooting

### Commands not recognized
Ensure the skill is in `~/.claude/skills/prd-manager/` and `SKILL.md` is present.

### Index not updating
The index is auto-generated. If it's stale, check the hooks in SKILL.md are configured.

### Chapter numbering issues
Chapter numbers are auto-assigned based on creation order. Use leading zeros: `01`, `02`, etc.

## Related Projects

- [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) - OMC multi-agent orchestration layer

## License

MIT License

## Contributing

Contributions welcome! Please open issues or PRs on GitHub.

## Changelog

### v4.0.0 (2026-03-19)
- Renamed from prd-manager to prd-manager
- Removed Sisyphus/Prometheus legacy references
- Updated to OMC workflow (autopilot / ralph / team)

### v3.1.0 (2026-02-02)
- Added date-indexed project naming: `YYMMDD-NN_project-name`
- Projects sorted chronologically by default
- Same-day projects get sequential index
- Reference projects by name only (auto-lookup)

### v1.0.0 (2026-01-20)
- Initial release with hierarchical PRD library structure
