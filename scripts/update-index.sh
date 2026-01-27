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

# Count files in directory
count_files() {
    local dir=$1
    if [ -d "$dir" ]; then
        find "$dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Count projects
PROJECT_COUNT=0
if [ -d "$TASKSUPERSTAR_DIR" ]; then
    PROJECT_COUNT=$(find "$TASKSUPERSTAR_DIR" -mindepth 1 -maxdepth 1 -type d -not -name "_inbox" -not -name "_archive" 2>/dev/null | wc -l | tr -d ' ')
fi

INBOX_COUNT=$(count_files "$TASKSUPERSTAR_DIR/_inbox")

# Generate index content
{
    echo "# TaskSuperstar Index"
    echo ""
    echo "**Last Updated:** ${TIMESTAMP}"
    echo ""

    # Projects section
    echo "## Projects (${PROJECT_COUNT})"
    echo ""
    if [ "$PROJECT_COUNT" -eq 0 ]; then
        echo "_No projects yet. Create one with \`/tasksuperstar new <project-name>\`_"
    else
        for project_dir in "$TASKSUPERSTAR_DIR"/*/; do
            if [ -d "$project_dir" ] && [ "$(basename "$project_dir")" != "_inbox" ] && [ "$(basename "$project_dir")" != "_archive" ]; then
                PROJECT_NAME=$(basename "$project_dir")
                MASTER_FILE="$project_dir/_master.md"

                if [ -f "$MASTER_FILE" ]; then
                    STATUS=$(grep "^status:" "$MASTER_FILE" | head -1 | cut -d' ' -f2 || echo "planned")
                    PHASE_COUNT=$(ls -1 "$project_dir"/phase-*.md 2>/dev/null | wc -l | tr -d ' ')

                    echo "### $PROJECT_NAME [$STATUS]"
                    echo ""
                    if [ "$PHASE_COUNT" -eq 0 ]; then
                        echo "_No phases yet. Add one with \`/tasksuperstar add $PROJECT_NAME <phase-name>\`_"
                    else
                        echo "| # | Phase | Status |"
                        echo "|---|-------|--------|"
                        for phase_file in "$project_dir"/phase-*.md; do
                            if [ -f "$phase_file" ]; then
                                FILENAME=$(basename "$phase_file" .md)
                                # Extract phase number (phase-01-name.md -> 01)
                                PHASE_NUM=$(echo "$FILENAME" | sed 's/phase-//' | cut -d'-' -f1)
                                # Extract phase name (phase-01-name.md -> name)
                                PHASE_NAME=$(echo "$FILENAME" | sed 's/phase-[0-9]*-//' | tr '-' ' ')
                                PHASE_STATUS=$(grep "^status:" "$phase_file" | head -1 | cut -d' ' -f2 || echo "planned")

                                echo "| $PHASE_NUM | $PHASE_NAME | $PHASE_STATUS |"
                            fi
                        done
                    fi
                    echo ""
                fi
            fi
        done
    fi

    # Inbox section
    echo "## Inbox (${INBOX_COUNT})"
    echo ""
    if [ "$INBOX_COUNT" -eq 0 ]; then
        echo "_No ideas yet. Create one with \`/tasksuperstar inbox <name>\`_"
    else
        for file in "$TASKSUPERSTAR_DIR/_inbox"/*.md; do
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

    # Recent archives
    echo "## Recently Archived"
    echo ""
    ARCHIVES=($(find "$TASKSUPERSTAR_DIR/_archive" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort -r | head -5))
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
