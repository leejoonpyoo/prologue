#!/bin/bash
# List projects and chapters
# Usage: ./list.sh [project]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
GRAY='\033[0;90m'
NC='\033[0m'

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"

if [ ! -d "$PROLOGUE_DIR" ]; then
    echo "Prologue not initialized. Run /prologue init"
    exit 1
fi

if [ -n "$PROJECT_NAME" ]; then
    # Show specific project's chapters
    PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_NAME"
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
    echo "Chapters:"

    for chapter in "$PROJECT_DIR"/chapter-*.md; do
        if [ -f "$chapter" ]; then
            BASENAME=$(basename "$chapter" .md)
            STATUS=$(grep "^status:" "$chapter" | head -1 | cut -d' ' -f2)
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

    for project_dir in "$PROLOGUE_DIR"/*/; do
        if [ -d "$project_dir" ] && [ "$(basename "$project_dir")" != "_inbox" ] && [ "$(basename "$project_dir")" != "_archive" ]; then
            PROJECT=$(basename "$project_dir")
            CHAPTER_COUNT=$(ls -1 "$project_dir"/chapter-*.md 2>/dev/null | wc -l | tr -d ' ')

            if [ -f "$project_dir/_master.md" ]; then
                STATUS=$(grep "^status:" "$project_dir/_master.md" | head -1 | cut -d' ' -f2)
            else
                STATUS="unknown"
            fi

            echo -e "  ${GREEN}$PROJECT${NC} - $CHAPTER_COUNT chapters [$STATUS]"
        fi
    done

    echo ""
    echo -e "${BLUE}=== Inbox ===${NC}"
    echo ""

    INBOX_DIR="$PROLOGUE_DIR/_inbox"
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
