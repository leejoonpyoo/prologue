#!/bin/bash
# Migrate TaskSuperstar v1 to v2
# Usage: ./migrate.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${RED}No TaskSuperstar directory found${NC}"
    exit 1
fi

# Check if already v2
if [ ! -d "$TASKSUPERSTAR_DIR/ideas" ] && [ ! -d "$TASKSUPERSTAR_DIR/drafts" ] && [ ! -d "$TASKSUPERSTAR_DIR/ready" ]; then
    echo -e "${GREEN}Already using v2 structure${NC}"
    exit 0
fi

echo -e "${BLUE}Migrating TaskSuperstar v1 → v2${NC}"
echo ""

# Create new structure
mkdir -p "$TASKSUPERSTAR_DIR/_inbox"

# Count items to migrate
IDEAS_COUNT=$(ls -1 "$TASKSUPERSTAR_DIR/ideas/"*.md 2>/dev/null | wc -l | tr -d ' ')
DRAFTS_COUNT=$(ls -1 "$TASKSUPERSTAR_DIR/drafts/"*.md 2>/dev/null | wc -l | tr -d ' ')
READY_COUNT=$(ls -1 "$TASKSUPERSTAR_DIR/ready/"*.md 2>/dev/null | wc -l | tr -d ' ')

echo "Found:"
echo "  - Ideas: $IDEAS_COUNT"
echo "  - Drafts: $DRAFTS_COUNT"
echo "  - Ready: $READY_COUNT"
echo ""

# Migrate ideas → inbox
if [ -d "$TASKSUPERSTAR_DIR/ideas" ]; then
    echo -e "${YELLOW}Migrating ideas to inbox...${NC}"
    for file in "$TASKSUPERSTAR_DIR/ideas/"*.md; do
        if [ -f "$file" ]; then
            BASENAME=$(basename "$file")
            mv "$file" "$TASKSUPERSTAR_DIR/_inbox/$BASENAME"
            echo "  → _inbox/$BASENAME"
        fi
    done
    rmdir "$TASKSUPERSTAR_DIR/ideas" 2>/dev/null || true
fi

# Migrate drafts → individual projects (single phase each)
if [ -d "$TASKSUPERSTAR_DIR/drafts" ]; then
    echo -e "${YELLOW}Migrating drafts to projects...${NC}"
    for file in "$TASKSUPERSTAR_DIR/drafts/"*.md; do
        if [ -f "$file" ]; then
            BASENAME=$(basename "$file" .md)
            PROJECT_DIR="$TASKSUPERSTAR_DIR/$BASENAME"
            mkdir -p "$PROJECT_DIR"

            # Create minimal master
            cat > "$PROJECT_DIR/_master.md" << EOF
---
status: planned
created: $TIMESTAMP
updated: $TIMESTAMP
---

# $BASENAME

## Vision
[Migrated from v1 draft]

## Phases

| # | Phase | Status | PRD |
|---|-------|--------|-----|
| 1 | Main | planned | phase-01-main.md |

## Notes
Migrated from TaskSuperstar v1 drafts/
EOF

            # Move draft as phase-01
            mv "$file" "$PROJECT_DIR/phase-01-main.md"

            # Update frontmatter in phase file
            sed -i '' '1s/^/---\nstatus: planned\nproject: '"$BASENAME"'\nphase: 1\n---\n\n/' "$PROJECT_DIR/phase-01-main.md" 2>/dev/null || true

            echo "  → $BASENAME/ (project with 1 phase)"
        fi
    done
    rmdir "$TASKSUPERSTAR_DIR/drafts" 2>/dev/null || true
fi

# Migrate ready → individual projects (marked ready)
if [ -d "$TASKSUPERSTAR_DIR/ready" ]; then
    echo -e "${YELLOW}Migrating ready PRDs to projects...${NC}"
    for file in "$TASKSUPERSTAR_DIR/ready/"*.md; do
        if [ -f "$file" ]; then
            BASENAME=$(basename "$file" .md)
            PROJECT_DIR="$TASKSUPERSTAR_DIR/$BASENAME"

            # Check if project already exists from drafts
            if [ -d "$PROJECT_DIR" ]; then
                # Add as additional phase
                PHASE_COUNT=$(ls -1 "$PROJECT_DIR"/phase-*.md 2>/dev/null | wc -l | tr -d ' ')
                NEXT_PHASE=$((PHASE_COUNT + 1))
                mv "$file" "$PROJECT_DIR/phase-0${NEXT_PHASE}-ready.md"
                echo "  → $BASENAME/phase-0${NEXT_PHASE}-ready.md (added to existing)"
            else
                mkdir -p "$PROJECT_DIR"

                # Create minimal master
                cat > "$PROJECT_DIR/_master.md" << EOF
---
status: ready
created: $TIMESTAMP
updated: $TIMESTAMP
---

# $BASENAME

## Vision
[Migrated from v1 ready]

## Phases

| # | Phase | Status | PRD |
|---|-------|--------|-----|
| 1 | Main | ready | phase-01-main.md |

## Notes
Migrated from TaskSuperstar v1 ready/
EOF

                # Move ready as phase-01
                mv "$file" "$PROJECT_DIR/phase-01-main.md"

                echo "  → $BASENAME/ (project with 1 phase, status: ready)"
            fi
        fi
    done
    rmdir "$TASKSUPERSTAR_DIR/ready" 2>/dev/null || true
fi

# Update index
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/update-index.sh" ]; then
    "$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
fi

echo ""
echo -e "${GREEN}Migration complete!${NC}"
echo ""
echo "New structure:"
echo "  .tasksuperstar/"
ls -la "$TASKSUPERSTAR_DIR" | grep "^d" | awk '{print "  ├── "$9"/"}'
echo ""
echo "Commands:"
echo "  /tasksuperstar list          # See all projects"
echo "  /tasksuperstar show <name>   # View project details"
