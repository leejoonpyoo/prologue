#!/bin/bash
# List all PRDs
# Usage: ./list.sh [status] [project-root]
# status: all, ideas, drafts, ready, archive

set -e

STATUS="${1:-all}"
PROJECT_ROOT="${2:-.}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    echo -e "${YELLOW}TaskSuperstar not initialized${NC}"
    echo "Run: /tasksuperstar init"
    exit 0
fi

list_folder() {
    local folder=$1
    local label=$2
    local color=$3
    local dir="$TASKSUPERSTAR_DIR/$folder"

    if [ ! -d "$dir" ]; then
        return
    fi

    local files=($(find "$dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort))
    local count=${#files[@]}

    echo -e "${color}## ${label} (${count})${NC}"
    echo ""

    if [ $count -eq 0 ]; then
        echo "  (empty)"
    else
        for file in "${files[@]}"; do
            local name=$(basename "$file" .md)
            local title=$(grep "^# " "$file" | head -1 | sed 's/^# //' || echo "$name")
            local priority=$(grep "^\*\*Priority:\*\*" "$file" | sed 's/.*: //' || echo "-")
            printf "  %-25s %s\n" "$name" "[$priority]"
        done
    fi
    echo ""
}

echo ""
echo -e "${BLUE}TaskSuperstar PRD Library${NC}"
echo "=========================="
echo ""

case "$STATUS" in
    ideas)
        list_folder "ideas" "Ideas" "$YELLOW"
        ;;
    drafts)
        list_folder "drafts" "Drafts" "$BLUE"
        ;;
    ready)
        list_folder "ready" "Ready" "$GREEN"
        ;;
    archive)
        list_folder "archive" "Archive" "$CYAN"
        ;;
    all|*)
        list_folder "ideas" "Ideas" "$YELLOW"
        list_folder "drafts" "Drafts" "$BLUE"
        list_folder "ready" "Ready" "$GREEN"

        # Show recent archives (last 5)
        ARCHIVE_DIR="$TASKSUPERSTAR_DIR/archive"
        if [ -d "$ARCHIVE_DIR" ]; then
            ARCHIVES=($(find "$ARCHIVE_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r | head -5))
            if [ ${#ARCHIVES[@]} -gt 0 ]; then
                echo -e "${CYAN}## Recent Archives${NC}"
                echo ""
                for file in "${ARCHIVES[@]}"; do
                    echo "  $(basename "$file" .md)"
                done
                echo ""
            fi
        fi
        ;;
esac

echo "Commands:"
echo "  /tasksuperstar idea <name>      Create new idea"
echo "  /tasksuperstar show <name>      View PRD details"
echo "  /tasksuperstar promote <name>   Promote to next stage"
