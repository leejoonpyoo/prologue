#!/bin/bash
# Prepare chapter PRD for Prometheus execution
# Usage: ./run.sh <project> <chapter>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_NAME="$1"
CHAPTER="$2"

if [ -z "$PROJECT_NAME" ] || [ -z "$CHAPTER" ]; then
    echo -e "${RED}Error: Project and chapter required${NC}"
    echo "Usage: /prologue run <project> <chapter>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
PROJECT_DIR="$PROLOGUE_DIR/$PROJECT_NAME"

# Find chapter file
CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-*-"$CHAPTER"*.md 2>/dev/null | head -1)
if [ -z "$CHAPTER_FILE" ]; then
    CHAPTER_FILE=$(ls "$PROJECT_DIR"/chapter-"$CHAPTER"-*.md 2>/dev/null | head -1)
fi

if [ ! -f "$CHAPTER_FILE" ]; then
    echo -e "${RED}Chapter not found: $CHAPTER${NC}"
    exit 1
fi

# Check status
STATUS=$(grep "^status:" "$CHAPTER_FILE" | head -1 | cut -d' ' -f2)
if [ "$STATUS" != "ready" ]; then
    echo -e "${YELLOW}Warning: Chapter status is '$STATUS', not 'ready'${NC}"
    echo "Consider: /prologue status $PROJECT_NAME $CHAPTER ready"
    echo ""
fi

echo -e "${BLUE}=== Prometheus Context ===${NC}"
echo ""
echo "Project: $PROJECT_NAME"
echo "Chapter: $CHAPTER"
echo "File: $CHAPTER_FILE"
echo ""
echo -e "${BLUE}--- PRD Content ---${NC}"
cat "$CHAPTER_FILE"
echo ""
echo -e "${BLUE}=======================${NC}"
echo ""
echo -e "${GREEN}Ready for: /prometheus${NC}"
echo "Copy the above content or reference the file path."
