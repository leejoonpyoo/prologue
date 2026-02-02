#!/bin/bash
# Archive a project
# Usage: ./archive.sh <project>

set -e

PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
TIMESTAMP=$(date "+%Y-%m-%d")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$PROJECT_NAME" ]; then
    echo "Usage: /prologue archive <project>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_NAME"
ARCHIVE_DIR="$PROLOGUE_DIR/_archive"

# Check inbox first
if [ -f "$PROLOGUE_DIR/_inbox/$PROJECT_NAME.md" ]; then
    mkdir -p "$ARCHIVE_DIR"
    mv "$PROLOGUE_DIR/_inbox/$PROJECT_NAME.md" "$ARCHIVE_DIR/${TIMESTAMP}_${PROJECT_NAME}.md"
    echo -e "${GREEN}Archived inbox idea: $PROJECT_NAME${NC}"
    "$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
    exit 0
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

mkdir -p "$ARCHIVE_DIR"

# Move entire project directory
mv "$PROJECT_DIR" "$ARCHIVE_DIR/${TIMESTAMP}_${PROJECT_NAME}"

echo -e "${GREEN}Archived project: $PROJECT_NAME${NC}"
echo "  → $ARCHIVE_DIR/${TIMESTAMP}_${PROJECT_NAME}/"

"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
