#!/bin/bash
# Show project or chapter details
# Usage: ./show.sh <project> [chapter]

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
CHAPTER="$2"

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: /prologue show <project> [chapter]"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_NAME"

# Check if it's an inbox item
if [ -f "$PROLOGUE_DIR/_inbox/$PROJECT_NAME.md" ]; then
    cat "$PROLOGUE_DIR/_inbox/$PROJECT_NAME.md"
    exit 0
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_NAME' not found${NC}"
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
