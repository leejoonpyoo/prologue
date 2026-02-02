#!/bin/bash
# Update index.md with current PRD status
# Usage: ./update-index.sh [project-root]

set -e

PROJECT_ROOT="${1:-.}"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

cd "$PROJECT_ROOT"

PROLOGUE_DIR=".prologue"
INDEX_FILE="$PROLOGUE_DIR/index.md"

if [ ! -d "$PROLOGUE_DIR" ]; then
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

# Extract display name from folder (YYMMDD-NN_name -> name, or just name)
get_display_name() {
    local folder="$1"
    # Check if it matches YYMMDD-NN_name pattern
    if [[ "$folder" =~ ^[0-9]{6}-[0-9]{2}_ ]]; then
        echo "$folder" | sed 's/^[0-9]*-[0-9]*_//'
    else
        echo "$folder"
    fi
}

# Count projects
PROJECT_COUNT=0
if [ -d "$PROLOGUE_DIR" ]; then
    PROJECT_COUNT=$(find "$PROLOGUE_DIR" -mindepth 1 -maxdepth 1 -type d -not -name "_inbox" -not -name "_archive" 2>/dev/null | wc -l | tr -d ' ')
fi

INBOX_COUNT=$(count_files "$PROLOGUE_DIR/_inbox")

# Generate index content
{
    echo "# Prologue Index"
    echo ""
    echo "**Last Updated:** ${TIMESTAMP}"
    echo ""

    # Projects section
    echo "## Projects (${PROJECT_COUNT})"
    echo ""
    if [ "$PROJECT_COUNT" -eq 0 ]; then
        echo "_No projects yet. Create one with \`/prologue new <project-name>\`_"
    else
        # Sort projects by folder name (which includes date prefix)
        for project_dir in $(find "$PROLOGUE_DIR" -mindepth 1 -maxdepth 1 -type d -not -name "_inbox" -not -name "_archive" 2>/dev/null | sort); do
            if [ -d "$project_dir" ]; then
                PROJECT_FOLDER=$(basename "$project_dir")
                PROJECT_DISPLAY=$(get_display_name "$PROJECT_FOLDER")
                MASTER_FILE="$project_dir/_master.md"

                if [ -f "$MASTER_FILE" ]; then
                    STATUS=$(grep "^status:" "$MASTER_FILE" | head -1 | cut -d' ' -f2 || echo "planned")
                    CHAPTER_COUNT=$(ls -1 "$project_dir"/chapter-*.md 2>/dev/null | wc -l | tr -d ' ')

                    echo "### $PROJECT_FOLDER [$STATUS]"
                    echo ""
                    if [ "$CHAPTER_COUNT" -eq 0 ]; then
                        echo "_No chapters yet. Add one with \`/prologue add $PROJECT_DISPLAY <chapter-name>\`_"
                    else
                        echo "| # | Chapter | Status |"
                        echo "|---|---------|--------|"
                        for chapter_file in "$project_dir"/chapter-*.md; do
                            if [ -f "$chapter_file" ]; then
                                FILENAME=$(basename "$chapter_file" .md)
                                # Extract chapter number (chapter-01-name.md -> 01)
                                CHAPTER_NUM=$(echo "$FILENAME" | sed 's/chapter-//' | cut -d'-' -f1)
                                # Extract chapter name (chapter-01-name.md -> name)
                                CHAPTER_NAME=$(echo "$FILENAME" | sed 's/chapter-[0-9]*-//' | tr '-' ' ')
                                CHAPTER_STATUS=$(grep "^status:" "$chapter_file" | head -1 | cut -d' ' -f2 || echo "planned")

                                echo "| $CHAPTER_NUM | $CHAPTER_NAME | $CHAPTER_STATUS |"
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
        echo "_No ideas yet. Create one with \`/prologue inbox <name>\`_"
    else
        for file in "$PROLOGUE_DIR/_inbox"/*.md; do
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
    ARCHIVES=($(find "$PROLOGUE_DIR/_archive" -maxdepth 1 \( -name "*.md" -o -type d \) -not -name "_archive" 2>/dev/null | sort -r | head -5))
    if [ ${#ARCHIVES[@]} -eq 0 ]; then
        echo "_No archived items yet._"
    else
        for item in "${ARCHIVES[@]}"; do
            NAME=$(basename "$item" .md)
            if [ -d "$item" ]; then
                echo "- [x] $NAME/ (project)"
            else
                echo "- [x] $NAME"
            fi
        done
    fi
    echo ""

    echo "---"
    echo ""
    echo "*This index is automatically updated by Prologue commands.*"
} > "$INDEX_FILE"
