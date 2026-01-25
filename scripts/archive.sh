#!/bin/bash
# Archive a PRD (completed or abandoned)
# Usage: ./archive.sh <name> [project-root]

set -e

NAME="${1:-}"
PROJECT_ROOT="${2:-.}"
DATE=$(date +%Y-%m-%d)
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
ARCHIVE_DIR="$TASKSUPERSTAR_DIR/archive"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${RED}Error: TaskSuperstar not initialized${NC}"
    exit 1
fi

# Find the PRD
SOURCE_FILE=""
SOURCE_TYPE=""

for folder in ideas drafts ready; do
    if [ -f "$TASKSUPERSTAR_DIR/$folder/${NAME}.md" ]; then
        SOURCE_FILE="$TASKSUPERSTAR_DIR/$folder/${NAME}.md"
        SOURCE_TYPE="$folder"
        break
    fi
done

if [ -z "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: PRD '${NAME}' not found${NC}"
    echo "Check: /tasksuperstar list"
    exit 1
fi

echo -e "${BLUE}Archiving ${SOURCE_TYPE}: ${NAME}${NC}"

# Create archive filename
ARCHIVE_NAME="${DATE}_${NAME}.md"
ARCHIVE_FILE="$ARCHIVE_DIR/$ARCHIVE_NAME"

# Handle duplicate names
if [ -f "$ARCHIVE_FILE" ]; then
    COUNTER=1
    while [ -f "${ARCHIVE_DIR}/${DATE}_${NAME}-${COUNTER}.md" ]; do
        ((COUNTER++))
    done
    ARCHIVE_NAME="${DATE}_${NAME}-${COUNTER}.md"
    ARCHIVE_FILE="$ARCHIVE_DIR/$ARCHIVE_NAME"
fi

# Add archive metadata
{
    echo ""
    echo "---"
    echo "**Archived:** ${TIMESTAMP}"
    echo "**Previous Status:** ${SOURCE_TYPE}"
} >> "$SOURCE_FILE"

# Move to archive
mv "$SOURCE_FILE" "$ARCHIVE_FILE"

echo -e "${GREEN}Archived to: ${ARCHIVE_FILE}${NC}"

# Update index
"$(dirname "${BASH_SOURCE[0]}")/update-index.sh" "$PROJECT_ROOT"

echo ""
echo "Archive location: $ARCHIVE_FILE"
