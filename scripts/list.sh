#!/bin/bash
# List projects and chapters
# Usage: ./list.sh [project]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_INPUT="$1"

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

# Find project directory by name (supports both old and new naming)
find_project_dir() {
    local name="$1"
    local slug=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

    # Try exact match first (old format)
    if [ -d "$PROLOGUE_DIR/$name" ]; then
        echo "$PROLOGUE_DIR/$name"
        return
    fi

    # Try new format: *_slug
    local found=$(find "$PROLOGUE_DIR" -maxdepth 1 -type d -name "*_${slug}" 2>/dev/null | head -1)
    if [ -n "$found" ]; then
        echo "$found"
        return
    fi

    # Try partial match
    found=$(find "$PROLOGUE_DIR" -maxdepth 1 -type d -name "*${slug}*" 2>/dev/null | head -1)
    if [ -n "$found" ]; then
        echo "$found"
    fi
}

if [ -n "$PROJECT_INPUT" ]; then
    # Show specific project's chapters
    PROJECT_DIR=$(find_project_dir "$PROJECT_INPUT")

    if [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]; then
        echo "Project '$PROJECT_INPUT' not found"
        exit 1
    fi

    PROJECT_FOLDER=$(basename "$PROJECT_DIR")
    echo -e "${BLUE}Project: $PROJECT_FOLDER${NC}"

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
            PROJECT_FOLDER=$(basename "$project_dir")
            CHAPTER_COUNT=$(ls -1 "$project_dir"/chapter-*.md 2>/dev/null | wc -l | tr -d ' ')

            if [ -f "$project_dir/_master.md" ]; then
                STATUS=$(grep "^status:" "$project_dir/_master.md" | head -1 | cut -d' ' -f2)
            else
                STATUS="unknown"
            fi

            echo -e "  ${GREEN}$PROJECT_FOLDER${NC} - $CHAPTER_COUNT chapters [$STATUS]"
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
