#!/bin/bash
# Update index.md with current PRD status
# Usage: ./update-index.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

cd "$PROJECT_ROOT"

TASKSUPERSTAR_DIR=".tasksuperstar"
INDEX_FILE="$TASKSUPERSTAR_DIR/index.md"

if [ ! -d "$TASKSUPERSTAR_DIR" ]; then
    exit 0
fi

# Count files in each folder
count_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

IDEAS_COUNT=$(count_files "$TASKSUPERSTAR_DIR/ideas")
DRAFTS_COUNT=$(count_files "$TASKSUPERSTAR_DIR/drafts")
READY_COUNT=$(count_files "$TASKSUPERSTAR_DIR/ready")

# Generate index content
{
    echo "# TaskSuperstar Index"
    echo ""
    echo "**Last Updated:** ${TIMESTAMP}"
    echo ""

    # Ideas section
    echo "## Ideas (${IDEAS_COUNT})"
    echo ""
    if [ "$IDEAS_COUNT" -eq 0 ]; then
        echo "_No ideas yet. Create one with \`/tasksuperstar idea <name>\`_"
    else
        for file in "$TASKSUPERSTAR_DIR/ideas"/*.md; do
            if [ -f "$file" ]; then
                NAME=$(basename "$file" .md)
                WHAT=$(grep -A 5 "## What" "$file" | tail -n +2 | head -1 | sed 's/^\[//' | sed 's/\]$//' | head -c 50 || echo "")
                if [ -n "$WHAT" ] && [ "$WHAT" != "[One sentence description]" ]; then
                    echo "- [ ] $NAME - \"$WHAT\""
                else
                    echo "- [ ] $NAME"
                fi
            fi
        done
    fi
    echo ""

    # Drafts section
    echo "## Drafts (${DRAFTS_COUNT})"
    echo ""
    if [ "$DRAFTS_COUNT" -eq 0 ]; then
        echo "_No drafts yet. Promote an idea with \`/tasksuperstar promote <name>\`_"
    else
        for file in "$TASKSUPERSTAR_DIR/drafts"/*.md; do
            if [ -f "$file" ]; then
                NAME=$(basename "$file" .md)
                PRIORITY=$(grep "^\*\*Priority:\*\*" "$file" | sed 's/^\*\*Priority:\*\* //' || echo "medium")
                echo "- [ ] $NAME [$PRIORITY]"
            fi
        done
    fi
    echo ""

    # Ready section
    echo "## Ready (${READY_COUNT})"
    echo ""
    if [ "$READY_COUNT" -eq 0 ]; then
        echo "_No ready PRDs yet. Promote a draft with \`/tasksuperstar promote <name>\`_"
    else
        for file in "$TASKSUPERSTAR_DIR/ready"/*.md; do
            if [ -f "$file" ]; then
                NAME=$(basename "$file" .md)
                PRIORITY=$(grep "^\*\*Priority:\*\*" "$file" | sed 's/^\*\*Priority:\*\* //' || echo "high")
                EFFORT=$(grep "^\*\*Estimated Effort:\*\*" "$file" | sed 's/^\*\*Estimated Effort:\*\* //' || echo "-")
                echo "- [ ] $NAME [$PRIORITY, $EFFORT]"
            fi
        done
    fi
    echo ""

    # Recent archives
    echo "## Recently Archived"
    echo ""
    ARCHIVES=($(find "$TASKSUPERSTAR_DIR/archive" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r | head -5))
    if [ ${#ARCHIVES[@]} -eq 0 ]; then
        echo "_No archived items yet._"
    else
        for file in "${ARCHIVES[@]}"; do
            NAME=$(basename "$file" .md)
            echo "- [x] $NAME"
        done
    fi
    echo ""

    echo "---"
    echo ""
    echo "*This index is automatically updated by TaskSuperstar commands.*"
} > "$INDEX_FILE"
