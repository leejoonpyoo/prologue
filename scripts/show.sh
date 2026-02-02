#!/bin/bash
# Show project or chapter details
# Usage: ./show.sh <project> [chapter]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_INPUT="$1"
CHAPTER="$2"

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$PROJECT_INPUT" ]; then
    echo "Usage: /prologue show <project> [chapter]"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"

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

# Check if it's an inbox item first
if [ -f "$PROLOGUE_DIR/_inbox/$PROJECT_INPUT.md" ]; then
    cat "$PROLOGUE_DIR/_inbox/$PROJECT_INPUT.md"
    exit 0
fi

PROJECT_DIR=$(find_project_dir "$PROJECT_INPUT")

if [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_INPUT' not found${NC}"
    exit 1
fi

if [ -z "$CHAPTER" ]; then
    # Show master
    if [ -f "$PROJECT_DIR/_master.md" ]; then
        cat "$PROJECT_DIR/_master.md"
    fi
else
    # Find and show chapter
    CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-*-"$CHAPTER"*.md 2>/dev/null | head -1)
    if [ -z "$CHAPTER_FILE" ]; then
        CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-"$CHAPTER"-*.md 2>/dev/null | head -1)
    fi

    if [ -f "$CHAPTER_FILE" ]; then
        cat "$CHAPTER_FILE"
    else
        echo -e "${RED}Chapter '$CHAPTER' not found${NC}"
        exit 1
    fi
fi
