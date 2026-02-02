#!/bin/bash
# Migrate TaskSuperstar v2 to Prologue v3
# Also migrates old project naming to YYMMDD-NN_name format
# Usage: ./migrate.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
DATE_PREFIX=$(date "+%y%m%d")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

cd "$PROJECT_ROOT"

OLD_DIR=".tasksuperstar"
NEW_DIR=".prologue"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Function to migrate project folder to new naming format
migrate_project_naming() {
    local prologue_dir="$1"

    echo -e "${YELLOW}Migrating project folders to YYMMDD-NN format...${NC}"

    local index=0
    for project_dir in "$prologue_dir"/*/; do
        if [ -d "$project_dir" ]; then
            local folder_name=$(basename "$project_dir")

            # Skip system folders
            if [ "$folder_name" = "_inbox" ] || [ "$folder_name" = "_archive" ]; then
                continue
            fi

            # Skip if already in new format (YYMMDD-NN_name)
            if [[ "$folder_name" =~ ^[0-9]{6}-[0-9]{2}_ ]]; then
                echo "  [skip] $folder_name (already new format)"
                continue
            fi

            # Get created date from _master.md or use today
            local created_date="$DATE_PREFIX"
            if [ -f "$project_dir/_master.md" ]; then
                local master_date=$(grep "^created:" "$project_dir/_master.md" | head -1 | cut -d' ' -f2 | tr -d '-')
                if [ -n "$master_date" ] && [ ${#master_date} -ge 6 ]; then
                    created_date="${master_date:2:6}"
                fi
            fi

            # Count existing projects with same date prefix
            index=$((index + 1))
            local index_padded=$(printf "%02d" $index)

            local new_folder_name="${created_date}-${index_padded}_${folder_name}"
            local new_path="$prologue_dir/$new_folder_name"

            mv "$project_dir" "$new_path"
            echo "  $folder_name → $new_folder_name"
        fi
    done
}

# Check for TaskSuperstar migration first
if [ -d "$OLD_DIR" ] && [ ! -d "$NEW_DIR" ]; then
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
    echo ""
fi

# Check if Prologue exists and migrate project naming
if [ -d "$NEW_DIR" ]; then
    # Check if any projects need naming migration
    needs_migration=false
    for project_dir in "$NEW_DIR"/*/; do
        if [ -d "$project_dir" ]; then
            folder_name=$(basename "$project_dir")
            if [ "$folder_name" != "_inbox" ] && [ "$folder_name" != "_archive" ]; then
                if [[ ! "$folder_name" =~ ^[0-9]{6}-[0-9]{2}_ ]]; then
                    needs_migration=true
                    break
                fi
            fi
        fi
    done

    if [ "$needs_migration" = true ]; then
        echo ""
        migrate_project_naming "$NEW_DIR"
    else
        echo -e "${GREEN}All projects already use YYMMDD-NN format${NC}"
    fi

    # Update index
    if [ -f "$SCRIPT_DIR/update-index.sh" ]; then
        "$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
    fi

    echo ""
    echo -e "${GREEN}Migration complete!${NC}"
    echo ""
    echo "Changes applied:"
    echo "  - .tasksuperstar/ → .prologue/ (if applicable)"
    echo "  - phase-*.md → chapter-*.md (if applicable)"
    echo "  - project-name/ → YYMMDD-NN_project-name/"
    echo "  - Updated all internal references"
    echo ""
    echo "Commands:"
    echo "  /prologue list          # See all projects"
    echo "  /prologue show <name>   # View project details"
else
    echo -e "${RED}No Prologue or TaskSuperstar directory found${NC}"
    echo "Run /prologue init to create a new Prologue structure"
    exit 1
fi
