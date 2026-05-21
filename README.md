# prd-manager

A Claude Code skill for hierarchical PRD (Product Requirements Document) library management. Plan complex multi-chapter projects, track execution progress, and hand off to OMC for execution.

## What is this?

prd-manager v5 manages projects as two distinct documents:

- `_master.md` — what you **planned** to build (vision, scope, chapters)
- `_progress.md` — what **actually happened** (execution state, decisions, resume point)

```
Project → Chapters (PRDs) → Execute → Progress Tracking → Next Chapter
```

### Key Features

- **AI-Assisted Planning**: Claude interviews you to draft `_master.md` and chapter PRDs
- **Progress Tracking**: Per-project `_progress.md` for resuming sessions with full context
- **Chapter-Based Organization**: Each chapter = one independently executable OMC session
- **Incremental Planning**: Add chapters as you go, not all upfront
- **OMC Integration**: `run` prepares execution context for autopilot/ralph/team — no `/oh-my-claudecode:plan` needed separately
- **Inbox**: Quick idea capture outside of active projects

### Key Concept: Plan vs Reality

`_master.md` is the plan. `_progress.md` is the reality. The separation keeps planning clean while tracking what actually gets built, what decisions were made, and where to resume next session.

### Project Naming: YYMMDD-NN Format

- Format: `YYMMDD-NN_project-name` (e.g., `260202-01_ba-platform`)
- Sorted chronologically by default
- Same-day projects get sequential index (01, 02, 03...)
- Reference projects by name only: `/prd-manager add ba-platform chapter`

## Installation

### Option 1: Symlink (recommended for development)

```bash
git clone https://github.com/leejoonpyoo/prd-manager.git ~/Developer/claude/prd-manager
ln -s ~/Developer/claude/prd-manager ~/.claude/skills/prd-manager
```

### Option 2: Copy

```bash
git clone https://github.com/leejoonpyoo/prd-manager.git
cp -r prd-manager ~/.claude/skills/prd-manager
```

### Verify Installation

```bash
/prd-manager list
```

## Quick Start

### 1. Create a Project (AI Interview)

```bash
/prd-manager new ba-platform
```

Claude interviews you and drafts `_master.md` with vision, scope, and proposed chapters.

### 2. Add First Chapter (AI Draft)

```bash
/prd-manager add ba-platform foundation
```

Claude reads `_master.md` and drafts `chapter-01-foundation.md` with goal, requirements, and technical approach.

### 3. Review PRD

```bash
/prd-manager review ba-platform foundation
```

Claude checks completeness and flags vague requirements before you commit to execution.

### 4. Execute

```bash
/prd-manager run ba-platform foundation
# → Creates _progress.md, outputs execution context summary
/oh-my-claudecode:autopilot  # or ralph / team
```

### 5. Capture Progress

```bash
/prd-manager update ba-platform foundation
# → Claude updates _progress.md with session results
```

### 6. Mark Done and Continue

```bash
/prd-manager status ba-platform foundation done
/prd-manager add ba-platform core-engine
```

## Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `new <project>` | AI interview → create project | `/prd-manager new ba-platform` |
| `add <project> <chapter>` | AI draft chapter PRD | `/prd-manager add ba-platform auth` |
| `review <project> <chapter>` | AI completeness check | `/prd-manager review ba-platform auth` |
| `run <project> <chapter>` | Execution handoff + update `_progress.md` | `/prd-manager run ba-platform auth` |
| `update <project> [chapter]` | AI updates progress doc | `/prd-manager update ba-platform auth` |
| `status <project> [chapter] <status>` | Change status | `/prd-manager status ba-platform auth ready` |
| `inbox <name>` | Quick idea capture | `/prd-manager inbox mobile-app` |
| `list [project]` | List projects or chapters | `/prd-manager list` |
| `show <project> [chapter]` | Show PRD content | `/prd-manager show ba-platform auth` |
| `archive <project>` | Archive completed project | `/prd-manager archive ba-platform` |
| `search <query>` | Search PRDs | `/prd-manager search authentication` |

## Folder Structure

```
.prd-manager/
├── _inbox/                              # Standalone ideas
├── _archive/                            # Completed projects
├── YYMMDD-NN_project-name/
│   ├── _master.md                       # Project vision & chapter registry
│   ├── _progress.md                     # Execution state & resume context
│   └── chapter-XX-xxx.md               # Chapter PRDs (added incrementally)
└── index.md                             # Master index
```

Example:
```
.prd-manager/
├── 260202-01_ba-platform/
│   ├── _master.md
│   ├── _progress.md
│   ├── chapter-01-foundation.md
│   └── chapter-02-api.md
└── index.md
```

## Status Flow

```
planned → ready → in-progress → done
```

- **planned**: PRD being written (use `add` + `review`)
- **ready**: PRD complete, ready to execute (use `run`)
- **in-progress**: Executing (use `update` to track progress)
- **done**: Complete

## Integration with OMC

prd-manager **replaces** `/oh-my-claudecode:plan` for managed projects. The `run` command handles execution preparation — no need for omc:plan separately.

```
prd-manager
    ├── _master.md + chapter-XX.md  (PRD)
    └── _progress.md                (execution state)
              ↓
    /prd-manager run
              ↓
    OMC: autopilot / ralph / team
              ↓
    /prd-manager update
              ↓
    archive when done
```

`.omc/plans/` is not used by prd-manager — no conflicts.

## Resuming Sessions

Attach `_progress.md` to your prompt when picking up work across sessions:

```bash
# Claude has full context on what was built, decisions made, and where to resume
/prd-manager run ba-platform core-engine
# _progress.md path is shown in the output — attach it to your next prompt
```

## Requirements

- Claude Code CLI
- oh-my-claudecode plugin (for autopilot/ralph/team execution)

## Changelog

### v5.0.0 (2026-05-21)
- Added AI-assisted workflows: interview for `new`, drafting for `add`, review for `review`, update for `update`
- Added `_progress.md` — project-level execution tracking for cross-session continuity
- Renamed folder: `.prologue/` → `.prd-manager/`
- Renamed repo: prologue → prd-manager
- `run` now replaces `/oh-my-claudecode:plan` — no need to run omc:plan separately
- Added `update` command for progress capture
- Added `review` command for PRD completeness check
- Removed Prometheus/Sisyphus legacy references

### v4.0.0 (2026-03-19)
- Renamed to prd-manager
- Updated to OMC workflow (autopilot / ralph / team)

### v3.1.0 (2026-02-02)
- Added date-indexed project naming: `YYMMDD-NN_project-name`
- Same-day projects get sequential index
- Reference projects by name only (auto-lookup)

### v1.0.0 (2026-01-20)
- Initial release
