#!/bin/bash
# Create new project with master plan
# Usage: ./new.sh <project-name>
# Project folder format: YYMMDD-NN_project-name

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
PROJECT_NAME="$1"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
DATE_PREFIX=$(date "+%y%m%d")
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
    echo "Usage: /prologue new <project-name>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"

# Create slug from project name
PROJECT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')

# Check if project with same name already exists (any date)
EXISTING=$(find "$PROLOGUE_DIR" -maxdepth 1 -type d -name "*_${PROJECT_SLUG}" 2>/dev/null | head -1)
if [ -n "$EXISTING" ]; then
    echo -e "${YELLOW}Project '$PROJECT_NAME' already exists: $(basename "$EXISTING")${NC}"
    exit 1
fi

# Count projects created today to determine index
TODAY_COUNT=$(find "$PROLOGUE_DIR" -maxdepth 1 -type d -name "${DATE_PREFIX}-*" 2>/dev/null | wc -l | tr -d ' ')
PROJECT_INDEX=$((TODAY_COUNT + 1))
PROJECT_INDEX_PADDED=$(printf "%02d" $PROJECT_INDEX)

# Create project folder with YYMMDD-NN_name format
PROJECT_FOLDER="${DATE_PREFIX}-${PROJECT_INDEX_PADDED}_${PROJECT_SLUG}"
PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_FOLDER"

mkdir -p "$PROJECT_DIR"

# Create master.md from template
sed -e "s/\${PROJECT_NAME}/$PROJECT_NAME/g" \
    -e "s/\${TIMESTAMP}/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/master.md" > "$PROJECT_DIR/_master.md"

echo -e "${GREEN}Created project: $PROJECT_FOLDER${NC}"
echo "  $PROJECT_DIR/_master.md"
echo ""
echo "Next: /prologue add $PROJECT_SLUG <chapter-name>"

# Update index
"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
