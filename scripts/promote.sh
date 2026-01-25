#!/bin/bash
# Promote PRD: idea → draft → ready
# Usage: ./promote.sh <name> [project-root]

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

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${RED}Error: TaskSuperstar not initialized${NC}"
    echo "Run: /tasksuperstar init"
    exit 1
fi

# Find the PRD
IDEA_FILE="$TASKSUPERSTAR_DIR/ideas/${NAME}.md"
DRAFT_FILE="$TASKSUPERSTAR_DIR/drafts/${NAME}.md"
READY_FILE="$TASKSUPERSTAR_DIR/ready/${NAME}.md"

if [ -f "$IDEA_FILE" ]; then
    # Promote idea → draft
    echo -e "${BLUE}Promoting idea to draft: ${NAME}${NC}"

    # Extract what/why from idea
    WHAT=$(grep -A 10 "## What" "$IDEA_FILE" | tail -n +2 | head -5 | grep -v "^##" | grep -v "^\[" | head -1 || echo "")
    WHY=$(grep -A 10 "## Why" "$IDEA_FILE" | tail -n +2 | head -5 | grep -v "^##" | grep -v "^\[" | head -1 || echo "")

    # Create draft with preserved content
    cat > "$DRAFT_FILE" << EOF
# Draft: ${NAME}

**Created:** ${TIMESTAMP}
**Status:** draft
**Priority:** medium
**Category:** feature

## Problem

${WHY:-[What problem does this solve?]}

## Proposed Solution

${WHAT:-[High-level approach]}

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

    rm "$IDEA_FILE"
    echo -e "${GREEN}Promoted to: ${DRAFT_FILE}${NC}"

elif [ -f "$DRAFT_FILE" ]; then
    # Promote draft → ready
    echo -e "${BLUE}Promoting draft to ready: ${NAME}${NC}"

    # Extract content from draft
    PROBLEM=$(grep -A 20 "## Problem" "$DRAFT_FILE" | tail -n +2 | head -10 | grep -v "^##" || echo "")
    SOLUTION=$(grep -A 20 "## Proposed Solution" "$DRAFT_FILE" | tail -n +2 | head -10 | grep -v "^##" || echo "")
    REQUIREMENTS=$(grep -A 20 "## Requirements" "$DRAFT_FILE" | tail -n +2 | head -10 | grep -v "^##" || echo "")
    PRIORITY=$(grep "^\*\*Priority:\*\*" "$DRAFT_FILE" | sed 's/.*: //' || echo "high")
    CATEGORY=$(grep "^\*\*Category:\*\*" "$DRAFT_FILE" | sed 's/.*: //' || echo "feature")

    # Create ready PRD
    cat > "$READY_FILE" << EOF
# PRD: ${NAME}

**Created:** ${TIMESTAMP}
**Status:** ready
**Priority:** ${PRIORITY}
**Category:** ${CATEGORY}
**Estimated Effort:** medium

## Problem Statement

${PROBLEM:-[Detailed problem description]}

## Goals

- Goal 1
- Goal 2

## Non-Goals

- What this will NOT do

## Proposed Solution

${SOLUTION:-[Detailed solution]}

## Requirements

### Functional

${REQUIREMENTS:-"- [ ] FR1: Description
- [ ] FR2: Description
- [ ] FR3: Description"}

### Non-Functional

- [ ] NFR1: Performance requirement
- [ ] NFR2: Security requirement

## Technical Approach

[Implementation details]

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
|      |            |

## Success Metrics

- Metric 1
- Metric 2

## Timeline

- Phase 1: Description
- Phase 2: Description

## Open Questions

- [ ] Resolved questions go here

## References

-
EOF

    rm "$DRAFT_FILE"
    echo -e "${GREEN}Promoted to: ${READY_FILE}${NC}"

elif [ -f "$READY_FILE" ]; then
    echo -e "${YELLOW}PRD '${NAME}' is already ready${NC}"
    echo "Next step: /prometheus $NAME to execute"
    exit 0
else
    echo -e "${RED}Error: PRD '${NAME}' not found${NC}"
    echo "Check: /tasksuperstar list"
    exit 1
fi

# Update index
"$(dirname "${BASH_SOURCE[0]}")/update-index.sh" "$PROJECT_ROOT"

echo ""
echo "Next steps:"
if [ -f "$DRAFT_FILE" ]; then
    echo "  1. Edit the draft: $DRAFT_FILE"
    echo "  2. When ready, promote: /tasksuperstar promote $NAME"
elif [ -f "$READY_FILE" ]; then
    echo "  1. Review the PRD: $READY_FILE"
    echo "  2. Execute with: /prometheus $NAME"
fi
