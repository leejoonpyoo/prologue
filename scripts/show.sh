#!/bin/bash
# Show PRD details
# Usage: ./show.sh <name> [project-root]

set -e

NAME="${1:-}"
PROJECT_ROOT="${2:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$NAME" ]; then
    echo -e "${RED}Error: Name required${NC}"
    echo "Usage: $0 <name> [project-root]"
    exit 1
fi

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${RED}Error: TaskSuperstar not initialized${NC}"
    exit 1
fi

# Find the PRD
FOUND_FILE=""
FOUND_TYPE=""

for folder in ideas drafts ready archive; do
    # Direct match
    if [ -f "$TASKSUPERSTAR_DIR/$folder/${NAME}.md" ]; then
        FOUND_FILE="$TASKSUPERSTAR_DIR/$folder/${NAME}.md"
        FOUND_TYPE="$folder"
        break
    fi
    # Archive match (with date prefix)
    if [ "$folder" = "archive" ]; then
        ARCHIVE_MATCH=$(find "$TASKSUPERSTAR_DIR/archive" -maxdepth 1 -name "*_${NAME}.md" -type f 2>/dev/null | head -1)
        if [ -n "$ARCHIVE_MATCH" ]; then
            FOUND_FILE="$ARCHIVE_MATCH"
            FOUND_TYPE="archive"
            break
        fi
    fi
done

if [ -z "$FOUND_FILE" ]; then
    echo -e "${RED}Error: PRD '${NAME}' not found${NC}"
    echo "Check: /tasksuperstar list"
    exit 1
fi

echo -e "${BLUE}Location: ${FOUND_FILE}${NC}"
echo -e "${BLUE}Status: ${FOUND_TYPE}${NC}"
echo ""
echo "---"
cat "$FOUND_FILE"
echo "---"
echo ""

# Show next actions based on type
case "$FOUND_TYPE" in
    ideas)
        echo "Actions:"
        echo "  /tasksuperstar promote $NAME    # Promote to draft"
        echo "  /tasksuperstar archive $NAME    # Archive"
        ;;
    drafts)
        echo "Actions:"
        echo "  /tasksuperstar promote $NAME    # Promote to ready"
        echo "  /tasksuperstar archive $NAME    # Archive"
        ;;
    ready)
        echo "Actions:"
        echo "  /prometheus $NAME               # Execute with Prometheus"
        echo "  /tasksuperstar archive $NAME    # Archive"
        ;;
    archive)
        echo "This PRD is archived."
        ;;
esac
