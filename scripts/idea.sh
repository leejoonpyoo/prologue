#!/bin/bash
# Create a new idea
# Usage: ./idea.sh <name> [project-root]

set -e

NAME="${1:-}"
PROJECT_ROOT="${2:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

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
IDEAS_DIR="$TASKSUPERSTAR_DIR/ideas"
IDEA_FILE="$IDEAS_DIR/${NAME}.md"

# Initialize if needed
if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/init.sh" "$PROJECT_ROOT"
fi

# Check if idea already exists
if [ -f "$IDEA_FILE" ]; then
    echo -e "${YELLOW}Idea '${NAME}' already exists${NC}"
    echo "File: $IDEA_FILE"
    exit 1
fi

# Check if exists in other folders
for folder in drafts ready; do
    if [ -f "$TASKSUPERSTAR_DIR/$folder/${NAME}.md" ]; then
        echo -e "${YELLOW}PRD '${NAME}' already exists in $folder/${NC}"
        echo "File: $TASKSUPERSTAR_DIR/$folder/${NAME}.md"
        exit 1
    fi
done

# Create idea
cat > "$IDEA_FILE" << EOF
# Idea: ${NAME}

**Created:** ${TIMESTAMP}
**Status:** idea

## What

[One sentence description]

## Why

[Why this matters]

## Notes

-
EOF

echo -e "${GREEN}Idea created: ${IDEA_FILE}${NC}"
echo ""

# Update index
"$(dirname "${BASH_SOURCE[0]}")/update-index.sh" "$PROJECT_ROOT"

echo "Next steps:"
echo "  1. Edit the idea: $IDEA_FILE"
echo "  2. When ready, promote: /tasksuperstar promote $NAME"
