#!/bin/bash
# Initialize TaskSuperstar v2.0 folder structure
# Usage: ./init.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"

if [ -d "$TASKSUPERSTAR_DIR" ]; then
    # Check if it's v1 structure
    if [ -d "$TASKSUPERSTAR_DIR/ideas" ] || [ -d "$TASKSUPERSTAR_DIR/drafts" ]; then
        echo -e "${YELLOW}TaskSuperstar v1 detected. Run migrate.sh to upgrade.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}TaskSuperstar already initialized${NC}"
    exit 0
fi

echo -e "${BLUE}Initializing TaskSuperstar v2.0...${NC}"

# Create folder structure (v2)
mkdir -p "$TASKSUPERSTAR_DIR/_inbox"
mkdir -p "$TASKSUPERSTAR_DIR/_archive"

# Create index.md from template
sed "s/\${TIMESTAMP}/$TIMESTAMP/g" "$TEMPLATE_DIR/index.md" > "$TASKSUPERSTAR_DIR/index.md"

echo ""
echo -e "${GREEN}TaskSuperstar v2.0 initialized!${NC}"
echo ""
echo "Structure:"
echo "  $TASKSUPERSTAR_DIR/"
echo "  ├── _inbox/       # Quick ideas"
echo "  ├── _archive/     # Completed projects"
echo "  ├── {projects}/   # Create with /tasksuperstar new <name>"
echo "  └── index.md      # Master index"
echo ""
echo "Commands:"
echo "  /tasksuperstar new <project>     # Create project"
echo "  /tasksuperstar inbox <idea>      # Quick idea"
echo "  /tasksuperstar list              # List all"
echo ""
