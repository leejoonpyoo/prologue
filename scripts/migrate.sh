#!/bin/bash
# Migrate TaskSuperstar v2 to Prologue v3
# Usage: ./migrate.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

OLD_DIR=".tasksuperstar"
NEW_DIR=".prologue"

# Check if already migrated
if [ -d "$NEW_DIR" ]; then
    echo -e "${GREEN}Already using Prologue v3 structure${NC}"
    exit 0
fi

# Check if old structure exists
if [ ! -d "$OLD_DIR" ]; then
    echo -e "${RED}No TaskSuperstar directory found${NC}"
    echo "Run /prologue init to create a new Prologue structure"
    exit 1
fi

echo -e "${BLUE}Migrating TaskSuperstar v2 → Prologue v3${NC}"
echo ""

# Rename the directory
mv "$OLD_DIR" "$NEW_DIR"
echo -e "${GREEN}Renamed .tasksuperstar/ → .prologue/${NC}"

# Rename all phase-*.md files to chapter-*.md
echo ""
echo -e "${YELLOW}Renaming phase files to chapter files...${NC}"

find "$NEW_DIR" -name "phase-*.md" -type f | while read -r file; do
    DIR=$(dirname "$file")
    BASENAME=$(basename "$file")
    NEW_NAME=$(echo "$BASENAME" | sed 's/^phase-/chapter-/')
    mv "$file" "$DIR/$NEW_NAME"
    echo "  $BASENAME → $NEW_NAME"
done

# Update references in all .md files
echo ""
echo -e "${YELLOW}Updating internal references...${NC}"

find "$NEW_DIR" -name "*.md" -type f | while read -r file; do
    # Update phase → chapter in content
    sed -i '' 's/phase-/chapter-/g' "$file" 2>/dev/null || true
    sed -i '' 's/Phase/Chapter/g' "$file" 2>/dev/null || true
    sed -i '' 's/phase:/chapter:/g' "$file" 2>/dev/null || true
    sed -i '' 's/Phases/Chapters/g' "$file" 2>/dev/null || true

    # Update tasksuperstar → prologue
    sed -i '' 's/tasksuperstar/prologue/g' "$file" 2>/dev/null || true
    sed -i '' 's/TaskSuperstar/Prologue/g' "$file" 2>/dev/null || true
done

echo "  Updated references in all .md files"

# Update index
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/update-index.sh" ]; then
    "$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
fi

echo ""
echo -e "${GREEN}Migration complete!${NC}"
echo ""
echo "Changes:"
echo "  - .tasksuperstar/ → .prologue/"
echo "  - phase-*.md → chapter-*.md"
echo "  - Updated all internal references"
echo ""
echo "Commands (updated):"
echo "  /prologue list          # See all projects"
echo "  /prologue show <name>   # View project details"
echo ""
