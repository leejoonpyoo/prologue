#!/bin/bash
# Show project or phase details
# Usage: ./show.sh <project> [phase]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
PHASE="$2"

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: /tasksuperstar show <project> [phase]"
    exit 1
fi

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"
PROJECT_DIR="$TASKSUPERSTAR_DIR/$PROJECT_NAME"

# Check if it's an inbox item
if [ -f "$TASKSUPERSTAR_DIR/inbox/$PROJECT_NAME.md" ]; then
    cat "$TASKSUPERSTAR_DIR/inbox/$PROJECT_NAME.md"
    exit 0
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

if [ -z "$PHASE" ]; then
    # Show master
    if [ -f "$PROJECT_DIR/_master.md" ]; then
        cat "$PROJECT_DIR/_master.md"
    fi
else
    # Find and show phase
    PHASE_FILE=$(ls "$PROJECT_DIR"/phase-*-"$PHASE"*.md 2>/dev/null | head -1)
    if [ -z "$PHASE_FILE" ]; then
        PHASE_FILE=$(ls "$PROJECT_DIR"/phase-"$PHASE"-*.md 2>/dev/null | head -1)
    fi

    if [ -f "$PHASE_FILE" ]; then
        cat "$PHASE_FILE"
    else
        echo -e "${RED}Phase '$PHASE' not found${NC}"
        exit 1
    fi
fi
