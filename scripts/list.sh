#!/bin/bash
# List projects and phases
# Usage: ./list.sh [project]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo "TaskSuperstar not initialized. Run /tasksuperstar init"
    exit 1
fi

if [ -n "$PROJECT_NAME" ]; then
    # Show specific project's phases
    PROJECT_DIR="$TASKSUPERSTAR_DIR/$PROJECT_NAME"
    if [ ! -d "$PROJECT_DIR" ]; then
        echo "Project '$PROJECT_NAME' not found"
        exit 1
    fi

    echo -e "${BLUE}Project: $PROJECT_NAME${NC}"

    # Show master status
    if [ -f "$PROJECT_DIR/_master.md" ]; then
        STATUS=$(grep "^status:" "$PROJECT_DIR/_master.md" | head -1 | cut -d' ' -f2)
        echo -e "  Status: ${GREEN}$STATUS${NC}"
    fi

    echo ""
    echo "Phases:"

    for phase in "$PROJECT_DIR"/phase-*.md; do
        if [ -f "$phase" ]; then
            BASENAME=$(basename "$phase" .md)
            STATUS=$(grep "^status:" "$phase" | head -1 | cut -d' ' -f2)
            case "$STATUS" in
                done) COLOR=$GRAY ;;
                in-progress) COLOR=$YELLOW ;;
                ready) COLOR=$GREEN ;;
                *) COLOR=$NC ;;
            esac
            echo -e "  - $BASENAME ${COLOR}[$STATUS]${NC}"
        fi
    done
else
    # List all projects
    echo -e "${BLUE}=== Projects ===${NC}"
    echo ""

    for project_dir in "$TASKSUPERSTAR_DIR"/*/; do
        if [ -d "$project_dir" ] && [ "$(basename "$project_dir")" != "_inbox" ] && [ "$(basename "$project_dir")" != "_archive" ]; then
            PROJECT=$(basename "$project_dir")
            PHASE_COUNT=$(ls -1 "$project_dir"/phase-*.md 2>/dev/null | wc -l | tr -d ' ')

            if [ -f "$project_dir/_master.md" ]; then
                STATUS=$(grep "^status:" "$project_dir/_master.md" | head -1 | cut -d' ' -f2)
            else
                STATUS="unknown"
            fi

            echo -e "  ${GREEN}$PROJECT${NC} - $PHASE_COUNT phases [$STATUS]"
        fi
    done

    echo ""
    echo -e "${BLUE}=== Inbox ===${NC}"
    echo ""

    INBOX_DIR="$TASKSUPERSTAR_DIR/_inbox"
    if [ -d "$INBOX_DIR" ]; then
        for idea in "$INBOX_DIR"/*.md; do
            if [ -f "$idea" ]; then
                NAME=$(basename "$idea" .md)
                echo "  - $NAME"
            fi
        done
    fi

    if [ -z "$(ls -A "$INBOX_DIR" 2>/dev/null)" ]; then
        echo "  (empty)"
    fi
fi
