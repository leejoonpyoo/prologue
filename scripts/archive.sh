#!/bin/bash
# Archive a project
# Usage: ./archive.sh <project>

set -e

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_INPUT="$1"
TIMESTAMP=$(date "+%Y-%m-%d")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$PROJECT_INPUT" ]; then
    echo "Usage: /prologue archive <project>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
ARCHIVE_DIR="$PROLOGUE_DIR/_archive"

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

# Check inbox first
if [ -f "$PROLOGUE_DIR/_inbox/$PROJECT_INPUT.md" ]; then
    mkdir -p "$ARCHIVE_DIR"
    mv "$PROLOGUE_DIR/_inbox/$PROJECT_INPUT.md" "$ARCHIVE_DIR/${TIMESTAMP}_${PROJECT_INPUT}.md"
    echo -e "${GREEN}Archived inbox idea: $PROJECT_INPUT${NC}"
    "$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
    exit 0
fi

PROJECT_DIR=$(find_project_dir "$PROJECT_INPUT")

if [ -z "$PROJECT_DIR" ] || [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_INPUT' not found${NC}"
    exit 1
fi

PROJECT_FOLDER=$(basename "$PROJECT_DIR")

mkdir -p "$ARCHIVE_DIR"

# Move entire project directory (keep original folder name)
mv "$PROJECT_DIR" "$ARCHIVE_DIR/$PROJECT_FOLDER"

echo -e "${GREEN}Archived project: $PROJECT_FOLDER${NC}"
echo "  → $ARCHIVE_DIR/$PROJECT_FOLDER/"

"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
