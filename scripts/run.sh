#!/bin/bash
# Prepare chapter PRD for Prometheus execution
# Usage: ./run.sh <project> <chapter>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_INPUT="$1"
CHAPTER="$2"

if [ -z "$PROJECT_INPUT" ] || [ -z "$CHAPTER" ]; then
    echo -e "${RED}Error: Project and chapter required${NC}"
    echo "Usage: /prologue run <project> <chapter>"
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

PROJECT_DIR=$(find_project_dir "$PROJECT_INPUT")

if [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_INPUT' not found${NC}"
    exit 1
fi

PROJECT_FOLDER=$(basename "$PROJECT_DIR")

# Find chapter file
CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-*-"$CHAPTER"*.md 2>/dev/null | head -1)
if [ -z "$CHAPTER_FILE" ]; then
    CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-"$CHAPTER"-*.md 2>/dev/null | head -1)
fi

if [ ! -f "$CHAPTER_FILE" ]; then
    echo -e "${RED}Chapter not found: $CHAPTER${NC}"
    exit 1
fi

# Check status
STATUS=$(grep "^status:" "$CHAPTER_FILE" | head -1 | cut -d' ' -f2)
if [ "$STATUS" != "ready" ]; then
    echo -e "${YELLOW}Warning: Chapter status is '$STATUS', not 'ready'${NC}"
    echo "Consider: /prologue status $PROJECT_INPUT $CHAPTER ready"
    echo ""
fi

echo -e "${BLUE}=== Prometheus Context ===${NC}"
echo ""
echo "Project: $PROJECT_FOLDER"
echo "Chapter: $CHAPTER"
echo "File: $CHAPTER_FILE"
echo ""
echo -e "${BLUE}--- PRD Content ---${NC}"
cat "$CHAPTER_FILE"
echo ""
echo -e "${BLUE}=======================${NC}"
echo ""
echo -e "${GREEN}Ready for: /prometheus${NC}"
echo "Copy the above content or reference the file path."
