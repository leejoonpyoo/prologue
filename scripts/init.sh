#!/bin/bash
# Initialize Prologue v3.0 folder structure
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

PROLOGUE_DIR=".prologue"

if [ -d "$PROLOGUE_DIR" ]; then
    echo -e "${YELLOW}Prologue already initialized${NC}"
    exit 0
fi

# Check for old TaskSuperstar structure
if [ -d ".tasksuperstar" ]; then
    echo -e "${YELLOW}TaskSuperstar v2 detected. Run /prologue migrate to upgrade.${NC}"
    exit 0
fi

echo -e "${BLUE}Initializing Prologue v3.0...${NC}"

# Create folder structure
mkdir -p "$PROLOGUE_DIR/_inbox"
mkdir -p "$PROLOGUE_DIR/_archive"

# Create index.md from template
sed "s/\${TIMESTAMP}/$TIMESTAMP/g" "$TEMPLATE_DIR/index.md" > "$PROLOGUE_DIR/index.md"

echo ""
echo -e "${GREEN}Prologue v3.0 initialized!${NC}"
echo ""
echo "Structure:"
echo "  $PROLOGUE_DIR/"
echo "  ├── _inbox/       # Quick ideas"
echo "  ├── _archive/     # Completed projects"
echo "  ├── {projects}/   # Create with /prologue new <name>"
echo "  └── index.md      # Master index"
echo ""
echo "Commands:"
echo "  /prologue new <project>     # Create project"
echo "  /prologue inbox <idea>      # Quick idea"
echo "  /prologue list              # List all"
echo ""
