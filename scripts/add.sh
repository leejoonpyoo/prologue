#!/bin/bash
# Add phase PRD to project
# Usage: ./add.sh <project> <phase-name>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
PHASE_NAME="$2"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ] || [ -z "$PHASE_NAME" ]; then
    echo -e "${RED}Error: Project and phase name required${NC}"
    echo "Usage: /tasksuperstar add <project> <phase-name>"
    exit 1
fi

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"
PROJECT_DIR="$TASKSUPERSTAR_DIR/$PROJECT_NAME"

if [ ! -d "$PROJECT_DIR" ]; then
    echo -e "${RED}Project '$PROJECT_NAME' not found${NC}"
    exit 1
fi

# Count existing phases to determine number
PHASE_COUNT=$(ls -1 "$PROJECT_DIR"/phase-*.md 2>/dev/null | wc -l | tr -d ' ')
PHASE_NUMBER=$((PHASE_COUNT + 1))
PHASE_NUM_PADDED=$(printf "%02d" $PHASE_NUMBER)

# Create slug from phase name
PHASE_SLUG=$(echo "$PHASE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

PHASE_FILE="$PROJECT_DIR/phase-${PHASE_NUM_PADDED}-${PHASE_SLUG}.md"

sed -e "s/\${PROJECT_NAME}/$PROJECT_NAME/g" \
    -e "s/\${PHASE_NAME}/$PHASE_NAME/g" \
    -e "s/\${PHASE_NUMBER}/$PHASE_NUMBER/g" \
    -e "s/\${TIMESTAMP}/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/phase.md" > "$PHASE_FILE"

echo -e "${GREEN}Added phase $PHASE_NUMBER: $PHASE_NAME${NC}"
echo "  $PHASE_FILE"

# Update master.md phases table
"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
