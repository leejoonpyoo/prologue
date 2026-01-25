#!/bin/bash
# Create a new draft directly (skipping idea stage)
# Usage: ./draft.sh <name> [project-root]

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
DRAFTS_DIR="$TASKSUPERSTAR_DIR/drafts"
DRAFT_FILE="$DRAFTS_DIR/${NAME}.md"

# Initialize if needed
if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "$SCRIPT_DIR/init.sh" "$PROJECT_ROOT"
fi

# Check if draft already exists
if [ -f "$DRAFT_FILE" ]; then
    echo -e "${YELLOW}Draft '${NAME}' already exists${NC}"
    echo "File: $DRAFT_FILE"
    exit 1
fi

# Check if exists in other folders
for folder in ideas ready; do
    if [ -f "$TASKSUPERSTAR_DIR/$folder/${NAME}.md" ]; then
        echo -e "${YELLOW}PRD '${NAME}' already exists in $folder/${NC}"
        echo "Use: /tasksuperstar promote $NAME"
        exit 1
    fi
done

# Create draft
cat > "$DRAFT_FILE" << EOF
# Draft: ${NAME}

**Created:** ${TIMESTAMP}
**Status:** draft
**Priority:** medium
**Category:** feature

## Problem

[What problem does this solve?]

## Proposed Solution

[High-level approach]

## Requirements

- [ ] Requirement 1
- [ ] Requirement 2
- [ ] Requirement 3

## Open Questions

- [ ] Question 1
- [ ] Question 2

## Notes

-
EOF

echo -e "${GREEN}Draft created: ${DRAFT_FILE}${NC}"
echo ""

# Update index
"$(dirname "${BASH_SOURCE[0]}")/update-index.sh" "$PROJECT_ROOT"

echo "Next steps:"
echo "  1. Edit the draft: $DRAFT_FILE"
echo "  2. When ready, promote: /tasksuperstar promote $NAME"
