#!/bin/bash
# Initialize TaskSuperstar folder structure
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
    echo -e "${YELLOW}TaskSuperstar already initialized at ${TASKSUPERSTAR_DIR}${NC}"
    exit 0
fi

echo -e "${BLUE}Initializing TaskSuperstar...${NC}"

# Create folder structure
mkdir -p "$TASKSUPERSTAR_DIR/ideas"
mkdir -p "$TASKSUPERSTAR_DIR/drafts"
mkdir -p "$TASKSUPERSTAR_DIR/ready"
mkdir -p "$TASKSUPERSTAR_DIR/archive"

# Create index.md
cat > "$TASKSUPERSTAR_DIR/index.md" << EOF
# TaskSuperstar Index

**Last Updated:** ${TIMESTAMP}

## Ideas (0)

_No ideas yet. Create one with \`/tasksuperstar idea <name>\`_

## Drafts (0)

_No drafts yet. Promote an idea with \`/tasksuperstar promote <name>\`_

## Ready (0)

_No ready PRDs yet. Promote a draft with \`/tasksuperstar promote <name>\`_

## Recently Archived

_No archived items yet._

---

*This index is automatically updated by TaskSuperstar commands.*
EOF

echo ""
echo -e "${GREEN}TaskSuperstar initialized!${NC}"
echo ""
echo "Folder structure:"
echo "  $TASKSUPERSTAR_DIR/"
echo "  ├── ideas/     # Quick ideas"
echo "  ├── drafts/    # Work-in-progress PRDs"
echo "  ├── ready/     # Ready for execution"
echo "  ├── archive/   # Completed/abandoned"
echo "  └── index.md   # Master index"
echo ""
echo "Commands:"
echo "  /tasksuperstar idea <name>    # Create new idea"
echo "  /tasksuperstar list           # List all PRDs"
