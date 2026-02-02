#!/bin/bash
# Search across all PRDs
# Usage: ./search.sh <query>

PROJECT_ROOT="${PROJECT_ROOT:-.}"
QUERY="$1"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

if [ -z "$QUERY" ]; then
    echo "Usage: /prologue search <query>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"

if [ ! -d "$PROLOGUE_DIR" ]; then
    echo "Prologue not initialized"
    exit 1
fi

echo -e "${BLUE}Searching for: $QUERY${NC}"
echo ""

# Search in all .md files
grep -ril "$QUERY" "$PROLOGUE_DIR" --include="*.md" 2>/dev/null | while read -r file; do
    REL_PATH="${file#$PROLOGUE_DIR/}"
    echo -e "${GREEN}$REL_PATH${NC}"
    grep -in "$QUERY" "$file" | head -3 | sed 's/^/  /'
    echo ""
done
