#!/bin/bash
# Change status of project or chapter
# Usage: ./status.sh <project> [chapter] <status>
# Status: planned | ready | in-progress | done

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Parse arguments
if [ $# -eq 2 ]; then
    PROJECT_NAME="$1"
    CHAPTER=""
    NEW_STATUS="$2"
elif [ $# -eq 3 ]; then
    PROJECT_NAME="$1"
    CHAPTER="$2"
    NEW_STATUS="$3"
else
    echo -e "${RED}Error: Invalid arguments${NC}"
    echo "Usage: /prologue status <project> [chapter] <status>"
    echo "Status: planned | ready | in-progress | done"
    exit 1
fi

# Validate status
case "$NEW_STATUS" in
    planned|ready|in-progress|done) ;;
    *)
        echo -e "${RED}Invalid status: $NEW_STATUS${NC}"
        echo "Valid: planned | ready | in-progress | done"
        exit 1
        ;;
esac

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

if [ -z "$CHAPTER" ]; then
    TARGET_FILE="$PROJECT_DIR/_master.md"
else
    TARGET_FILE=$(ls "$PROJECT_DIR"/chapter-*-"$CHAPTER"*.md 2>/dev/null | head -1)
    if [ -z "$TARGET_FILE" ]; then
        TARGET_FILE=$(ls "$PROJECT_DIR"/chapter-"$CHAPTER"-*.md 2>/dev/null | head -1)
    fi
fi

if [ ! -f "$TARGET_FILE" ]; then
    echo -e "${RED}File not found${NC}"
    exit 1
fi

# Update status in frontmatter
sed -i '' "s/^status: .*/status: $NEW_STATUS/" "$TARGET_FILE"
sed -i '' "s/^updated: .*/updated: $TIMESTAMP/" "$TARGET_FILE"

echo -e "${GREEN}Updated status to: $NEW_STATUS${NC}"
echo "  $TARGET_FILE"
