#!/bin/bash
# Create new project with master plan
# Usage: ./new.sh <project-name>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Error: Project name required${NC}"
    echo "Usage: /tasksuperstar new <project-name>"
    exit 1
fi

TASKSUPERSTAR_DIR="$PROJECT_ROOT/.tasksuperstar"
PROJECT_DIR="$TASKSUPERSTAR_DIR/$PROJECT_NAME"

if [ -d "$PROJECT_DIR" ]; then
    echo -e "${YELLOW}Project '$PROJECT_NAME' already exists${NC}"
    exit 1
fi

mkdir -p "$PROJECT_DIR"

# Create master.md from template
sed -e "s/\${PROJECT_NAME}/$PROJECT_NAME/g" \
    -e "s/\${TIMESTAMP}/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/master.md" > "$PROJECT_DIR/_master.md"

echo -e "${GREEN}Created project: $PROJECT_NAME${NC}"
echo "  $PROJECT_DIR/_master.md"
echo ""
echo "Next: /tasksuperstar add $PROJECT_NAME <phase-name>"

# Update index
"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
