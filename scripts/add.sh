#!/bin/bash
# Add chapter PRD to project
# Usage: ./add.sh <project> <chapter-name>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_INPUT="$1"
CHAPTER_NAME="$2"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$PROJECT_INPUT" ] || [ -z "$CHAPTER_NAME" ]; then
    echo -e "${RED}Error: Project and chapter name required${NC}"
    echo "Usage: /prologue add <project> <chapter-name>"
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

# Count existing chapters to determine number
CHAPTER_COUNT=$(ls -1 "$PROJECT_DIR"/chapter-*.md 2>/dev/null | wc -l | tr -d ' ')
CHAPTER_NUMBER=$((CHAPTER_COUNT + 1))
CHAPTER_NUM_PADDED=$(printf "%02d" $CHAPTER_NUMBER)

# Create slug from chapter name
CHAPTER_SLUG=$(echo "$CHAPTER_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

CHAPTER_FILE="$PROJECT_DIR/chapter-${CHAPTER_NUM_PADDED}-${CHAPTER_SLUG}.md"

# Extract project name from master.md or folder
PROJECT_NAME=$(grep "^# " "$PROJECT_DIR/_master.md" 2>/dev/null | head -1 | sed 's/^# //' || echo "$PROJECT_FOLDER")

sed -e "s/\${PROJECT_NAME}/$PROJECT_NAME/g" \
    -e "s/\${CHAPTER_NAME}/$CHAPTER_NAME/g" \
    -e "s/\${CHAPTER_NUMBER}/$CHAPTER_NUMBER/g" \
    -e "s/\${TIMESTAMP}/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/chapter.md" > "$CHAPTER_FILE"

echo -e "${GREEN}Added chapter $CHAPTER_NUMBER: $CHAPTER_NAME${NC}"
echo "  $CHAPTER_FILE"

# Update master.md chapters table
"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
