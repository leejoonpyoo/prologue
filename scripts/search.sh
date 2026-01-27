#!/bin/bash
# Search across all PRDs
# Usage: ./search.sh <query>

PROJECT_ROOT="${PROJECT_ROOT:-.}"
QUERY="$1"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$QUERY" ]; then
    echo "Usage: /tasksuperstar search <query>"
    exit 1
fi

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo "TaskSuperstar not initialized"
    exit 1
fi

echo -e "${BLUE}Searching for: $QUERY${NC}"
echo ""

# Search in all .md files
grep -ril "$QUERY" "$TASKSUPERSTAR_DIR" --include="*.md" 2>/dev/null | while read -r file; do
    REL_PATH="${file#$TASKSUPERSTAR_DIR/}"
    echo -e "${GREEN}$REL_PATH${NC}"
    grep -in "$QUERY" "$file" | head -3 | sed 's/^/  /'
    echo ""
done
