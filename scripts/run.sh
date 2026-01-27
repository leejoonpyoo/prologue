#!/bin/bash
# Prepare phase PRD for Prometheus execution
# Usage: ./run.sh <project> <phase>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME="$1"
PHASE="$2"

if [ -z "$PROJECT_NAME" ] || [ -z "$PHASE" ]; then
    echo -e "${RED}Error: Project and phase required${NC}"
    echo "Usage: /tasksuperstar run <project> <phase>"
    exit 1
fi

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"
PROJECT_DIR="$TASKSUPERSTAR_DIR/$PROJECT_NAME"

# Find phase file
PHASE_FILE=$(ls "$PROJECT_DIR"/phase-*-"$PHASE"*.md 2>/dev/null | head -1)
if [ -z "$PHASE_FILE" ]; then
    PHASE_FILE=$(ls "$PROJECT_DIR"/phase-"$PHASE"-*.md 2>/dev/null | head -1)
fi

if [ ! -f "$PHASE_FILE" ]; then
    echo -e "${RED}Phase not found: $PHASE${NC}"
    exit 1
fi

# Check status
STATUS=$(grep "^status:" "$PHASE_FILE" | head -1 | cut -d' ' -f2)
if [ "$STATUS" != "ready" ]; then
    echo -e "${YELLOW}Warning: Phase status is '$STATUS', not 'ready'${NC}"
    echo "Consider: /tasksuperstar status $PROJECT_NAME $PHASE ready"
    echo ""
fi

echo -e "${BLUE}=== Prometheus Context ===${NC}"
echo ""
echo "Project: $PROJECT_NAME"
echo "Phase: $PHASE"
echo "File: $PHASE_FILE"
echo ""
echo -e "${BLUE}--- PRD Content ---${NC}"
cat "$PHASE_FILE"
echo ""
echo -e "${BLUE}=======================${NC}"
echo ""
echo -e "${GREEN}Ready for: /prometheus${NC}"
echo "Copy the above content or reference the file path."
