---
name: prd-manager
description: Manage complex projects as hierarchical PRD libraries — master plan, executable chapters, and progress tracking. Use when planning a multi-step project, breaking an initiative into independently executable chunks, tracking execution progress across sessions, capturing quick ideas, or preparing work for OMC (autopilot/ralph/team). This skill handles the full planning → execution lifecycle so you don't need /oh-my-claudecode:plan separately for managed projects.
version: 5.0.0
author: leejoonpyoo
---

## Overview

prd-manager manages projects as two distinct documents:

- `_master.md` — what you **planned** to build (vision, scope, chapters)
- `_progress.md` — what **actually happened** (execution state, decisions, resume point)

```
Project → Chapters (PRDs) → Execute → Progress Tracking → Next Chapter
```

## Commands

| Command | Description |
|---------|-------------|
| `/prd-manager new <project>` | AI interview → creates project + drafts `_master.md` |
| `/prd-manager add <project> <chapter>` | AI drafts chapter PRD from master plan context |
| `/prd-manager review <project> <chapter>` | AI reviews PRD completeness → ready to execute? |
| `/prd-manager run <project> <chapter>` | Prepares execution context + creates/updates `_progress.md` |
| `/prd-manager update <project> [chapter]` | AI updates `_progress.md` from current session |
| `/prd-manager status <project> [chapter] <status>` | Change status (planned/ready/in-progress/done) |
| `/prd-manager inbox <name>` | Quick idea capture (AI-assisted) |
| `/prd-manager list [project]` | List projects or chapters |
| `/prd-manager show <project> [chapter]` | Show PRD content |
| `/prd-manager archive <project>` | Archive completed project |
| `/prd-manager search <query>` | Search all PRDs |

## Key Concept: Chapters

**Chapters are independent work units, NOT refinement stages.**

- All chapters have the same level of detail (fully executable PRDs)
- Chapter numbers = execution order, not maturity
- Each chapter = one OMC session
- Add chapters incrementally — not all upfront

## Folder Structure

```
.prd-manager/
├── _inbox/                              # Standalone ideas
├── _archive/                            # Completed projects
├── YYMMDD-NN_project-name/
│   ├── _master.md                       # Project vision & chapter registry (the plan)
│   ├── _progress.md                     # Execution reality & resume context
│   └── chapter-XX-xxx.md               # Chapter PRDs (added incrementally)
├── index.md                             # Master index
└── todo.md                              # Active chapter execution checklist (run으로 생성)
```

## Project Naming: YYMMDD-NN Format

- Format: `YYMMDD-NN_project-name` (e.g., `260202-01_ba-platform`)
- Sorted chronologically; same-day projects get sequential index
- Reference projects by name only — the system resolves the full folder

## AI Workflows

### `new` — Project Interview

Interview the user to draft `_master.md` rather than leaving them with a blank template:

1. "이 프로젝트는 무엇을 하나요? (1-2문장)"
2. "주요 deliverable은 무엇인가요?"
3. "스코프 외 항목이 있나요?"
4. Propose a natural chapter breakdown based on the answers
5. Run `scripts/new.sh` to create the folder, then write the drafted content into `_master.md`

### `add` — Chapter Drafting

Don't create an empty template — use project context to draft a meaningful starting point:

1. Read `_master.md` for vision, scope, and chapter plan
2. Read existing chapter files to understand what's already covered
3. Draft the new chapter: Goal, Scope, Requirements, Technical Approach, Dependencies
4. Run `scripts/add.sh` to create the file, then write the draft

### `review` — PRD Completeness Check

Before marking a chapter ready, verify it's truly executable:

- Goal is specific and measurable
- Requirements are concrete (not "improve performance" — write "p99 < 100ms")
- Technical Approach has enough detail to start coding
- Dependencies are named, not vague
- Success Criteria are testable

Point out vague or missing sections explicitly. Only recommend marking ready when all of the above are met.

**High-risk chapters** (auth/security, data migration, breaking API changes, production-impacting): spawn `Task(subagent_type="oh-my-claudecode:critic", ...)` for an independent review pass. Tell the user: "고위험 chapter로 판단하여 Critic 리뷰를 추가로 실행합니다." Apply the Critic's feedback before recommending ready.

### `run` — Execution Handoff

This replaces `/oh-my-claudecode:plan` for managed projects. Do NOT write to `.omc/plans/`.

1. Run `scripts/run.sh` to locate and display the chapter PRD
2. Read `_master.md` and the chapter PRD
3. Read `_progress.md` if it exists — check for prior context on this chapter
4. Create or update `_progress.md`: add/refresh the "현재 진행 중" section for this chapter
5. Create or overwrite `.prd-manager/todo.md` from the chapter PRD:
   - Map chapter's Requirements → task checklist items
   - Map chapter's Success Criteria → acceptance criteria section
   - Add standard execution steps (설계 → 구현 → 테스트 → 검증)
6. Output an execution summary:
   - What this chapter builds and why
   - Key constraints and dependencies from prior chapters
   - Concrete starting point
   - Recommended OMC mode: `autopilot` (autonomous), `ralph` (with review loop), `team` (multi-agent)
7. Tell the user: "실행 준비 완료. `/oh-my-claudecode:autopilot` (또는 ralph/team) 실행하세요. 세션 중 컨텍스트 복원이 필요하면 `_progress.md`를 프롬프트에 첨부하세요."

### `update` — Progress Capture

After an execution session, capture what happened:

1. Ask: "이번 세션에서 무엇을 완료했나요? 어떤 결정을 내렸나요? 다음 세션 시작점은 어디인가요?"
2. Update `_progress.md`:
   - Move completed items to "완료된 것"
   - Update "진행 중" and "다음 세션 시작점"
   - Record new decisions in "결정 사항"
3. Update `.prd-manager/todo.md`: check off completed items based on what the user reported
4. If the chapter is fully done, prompt: "`/prd-manager status <project> <chapter> done` 실행할까요?"

### `inbox` — Quick Capture

Ask for a one-sentence description, then draft a minimal What/Why. Keep it fast — inbox is for capture, not planning.

## Status Flow

```
planned → ready → in-progress → done
```

- **planned**: PRD being written (use `add` + `review`)
- **ready**: PRD complete, ready to execute (use `run`)
- **in-progress**: Executing (use `update` to track progress)
- **done**: Complete

## Integration with OMC

prd-manager **replaces** `/oh-my-claudecode:plan` for managed projects. The `run` command handles all execution preparation.

```
prd-manager
    ├── _master.md + chapter-XX.md  (PRD — what to build)
    └── _progress.md                (reality — what happened)
              ↓
    /prd-manager run
              ↓
    OMC Execution: autopilot / ralph / team
              ↓
    /prd-manager update
              ↓
    archive when done
```

`.omc/plans/` is not used by prd-manager — no conflicts.

## Templates

### _master.md

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
| 01 | {name} | planned | [Brief description] |

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Notes

-
```

### chapter-XX-xxx.md

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

### Non-Functional
- [ ] NFR1: Performance/security requirement

## Technical Approach

[How will this be implemented?]

## Dependencies

- Depends on: [Previous chapters or external dependencies]
- Enables: [What this chapter unlocks]

## Success Criteria

- [ ] Criterion 1
- [ ] Criterion 2

## Notes

-
```

### _progress.md

```markdown
# Progress: {project-name}
**Last Updated:** {timestamp}

## Chapter 상태 요약

| Chapter | Name | Status | Updated |
|---------|------|--------|---------|
| 01 | {name} | in-progress | {date} |

## 현재 진행 중: chapter-01-{name}

### 완료된 것
-

### 진행 중
-

### 다음 세션 시작점
[여기서부터 시작하세요 — 구체적인 파일, 함수, 작업 단위]

### 결정 사항
- [X 대신 Y를 선택한 이유]

### 블로커
- 없음

## 히스토리

### chapter-01-{name} (done, {date})
실제로 만들어진 것 요약 + 주요 결정
```

### todo.md

```markdown
# Todo: {chapter-name}
**Project:** {project-name}
**Chapter:** {XX}
**Generated:** {timestamp}

## Acceptance Criteria
- [ ] (chapter Success Criteria에서 복사)

## Tasks
- [ ] 목표 + acceptance criteria 재서술
- [ ] 기존 구현/패턴 위치 파악
- [ ] 설계: 최소 접근법 + 주요 결정
- [ ] 가장 안전한 슬라이스 구현
- [ ] 테스트 추가/조정
- [ ] 검증 실행 (lint/tests/build/manual)
- [ ] 변경사항 + 검증 스토리 요약
- [ ] 교훈 기록 (있을 경우)

## Requirements
- [ ] FR1: (chapter Functional Requirements에서 복사)
- [ ] NFR1: (chapter Non-Functional Requirements에서 복사)
```

### _inbox/xxx.md

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
# 1. Create project (AI interview → drafts _master.md)
/prd-manager new ba-platform

# 2. Add first chapter (AI drafts from master plan)
/prd-manager add ba-platform foundation

# 3. Review PRD before executing
/prd-manager review ba-platform foundation

# 4. Execute
/prd-manager run ba-platform foundation
# → _progress.md 생성, 실행 컨텍스트 요약 출력
/oh-my-claudecode:autopilot  # or ralph / team

# 5. Capture session progress
/prd-manager update ba-platform foundation

# 6. Done → next chapter
/prd-manager status ba-platform foundation done
/prd-manager add ba-platform core-engine
```

## Best Practices

1. **One project per major initiative** — don't mix unrelated work
2. **Chapters = one OMC session** — keep them independently executable
3. **Add chapters incrementally** — plan each chapter when ready, not all upfront
4. **Attach `_progress.md` to resume** — gives Claude full execution context across sessions
5. **Let AI draft, you refine** — `add` and `review` give you a strong starting point
6. **Keep `_master.md` current** — update the chapters table as status changes
7. **Archive when done** — clean active view, preserve history

## Version History

| Version | Folder | Key Change |
|---------|--------|------------|
| v2 (TaskSuperstar) | .tasksuperstar/ | Original |
| v4 | .prologue/ | Renamed from TaskSuperstar |
| v5 (current) | .prd-manager/ | AI workflows + `_progress.md` + folder rename |
