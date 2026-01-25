#!/bin/bash
# Search PRDs by content
# Usage: ./search.sh <query> [project-root]

set -e

QUERY="${1:-}"
PROJECT_ROOT="${2:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ -z "$QUERY" ]; then
    echo -e "${RED}Error: Search query required${NC}"
    echo "Usage: $0 <query> [project-root]"
    exit 1
fi

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${RED}Error: TaskSuperstar not initialized${NC}"
    exit 1
fi

echo -e "${BLUE}Searching for: ${QUERY}${NC}"
echo ""

FOUND=0

for folder in ideas drafts ready archive; do
    DIR="$TASKSUPERSTAR_DIR/$folder"
    if [ ! -d "$DIR" ]; then
        continue
    fi

    # Search in folder
    RESULTS=$(grep -l -i "$QUERY" "$DIR"/*.md 2>/dev/null || true)

    if [ -n "$RESULTS" ]; then
        echo -e "${CYAN}## ${folder}${NC}"
        for file in $RESULTS; do
            NAME=$(basename "$file" .md)
            CONTEXT=$(grep -i -m 1 "$QUERY" "$file" | head -c 80 || echo "")
            echo "  $NAME"
            if [ -n "$CONTEXT" ]; then
                echo "    > $CONTEXT..."
            fi
            ((FOUND++))
        done
        echo ""
    fi
done

if [ $FOUND -eq 0 ]; then
    echo -e "${YELLOW}No results found for '${QUERY}'${NC}"
else
    echo -e "${GREEN}Found ${FOUND} result(s)${NC}"
fi

echo ""
echo "Use: /tasksuperstar show <name> to view details"
