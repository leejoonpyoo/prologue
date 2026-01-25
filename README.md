# Claude TaskSuperstar

A Claude Code skill for PRD (Product Requirements Document) library management and brainstorming storage.

## What is this?

TaskSuperstar is a **lightweight PRD library** for capturing and organizing ideas before execution. Unlike Prometheus (which plans for immediate execution), TaskSuperstar stores ideas for future reference.

```
Idea → Draft → Ready → (later) /prometheus → Execute
```

Part of the **Sisyphus Multi-Agent System**.

### Key Features

- **Idea Capture**: Quick capture of rough ideas
- **Progressive Refinement**: Ideas → Drafts → Ready PRDs
- **Prometheus Integration**: Ready PRDs can feed into Prometheus for execution
- **Index Management**: Automatic tracking of all PRDs

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

## Usage

### Commands

```bash
/tasksuperstar idea <name>      # Create new idea (minimal)
/tasksuperstar draft <name>     # Create draft PRD (structured)
/tasksuperstar promote <name>   # Promote: idea → draft → ready
/tasksuperstar list [status]    # List all PRDs
/tasksuperstar show <name>      # Show PRD details
/tasksuperstar archive <name>   # Archive PRD
/tasksuperstar search <query>   # Search PRDs
```

### Folder Structure

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

## Workflow

### 1. Capture Ideas

```bash
/tasksuperstar idea mobile-app
# Creates .tasksuperstar/ideas/mobile-app.md
```

### 2. Develop into Draft

```bash
/tasksuperstar promote mobile-app
# Moves to .tasksuperstar/drafts/mobile-app.md
# Expands template with more structure
```

### 3. Finalize as Ready PRD

```bash
/tasksuperstar promote mobile-app
# Moves to .tasksuperstar/ready/mobile-app.md
# Full PRD template
```

### 4. Execute (with Prometheus)

```bash
/prometheus mobile-app
# Reads .tasksuperstar/ready/mobile-app.md as context
# Creates execution plan in .sisyphus/plans/
```

## Integration with Sisyphus

TaskSuperstar sits **before** the Sisyphus execution pipeline:

```
TaskSuperstar (PRD Library)
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

## Templates

### Idea (Minimal)
- What: One sentence description
- Why: Why this matters
- Notes: Additional thoughts

### Draft (Structured)
- Problem: What problem does this solve?
- Proposed Solution: High-level approach
- Requirements: Checklist of needs
- Open Questions: Unknowns to resolve

### Ready (Full PRD)
- Problem Statement
- Goals / Non-Goals
- Requirements (Functional / Non-Functional)
- Technical Approach
- Risks & Mitigations
- Success Metrics
- Timeline

## Best Practices

1. **Capture immediately**: When you have an idea, create it instantly
2. **Don't over-polish ideas**: Ideas are meant to be rough
3. **Promote when ready**: Move to draft only when you want to think more deeply
4. **Ready means ready**: Only promote to ready when you could execute tomorrow
5. **Archive freely**: Don't delete - archive for future reference

## Requirements

- Claude Code CLI
- (Optional) Prometheus agent for execution
- (Optional) planning-with-files skill for execution context

## Related Projects

- [claude-task-planning](https://github.com/leejoonpyoo/claude-task-planning) - Execution context management
- [Sisyphus Multi-Agent System](https://github.com/leejoonpyoo/sisyphus) - Full orchestration system

## License

MIT License
