#!/bin/bash
# Create standalone idea in inbox
# Usage: ./inbox.sh <name>

set -e
PROJECT_ROOT="${PROJECT_ROOT:-.}"
NAME="$1"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$(dirname "$SCRIPT_DIR")/templates"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

if [ -z "$NAME" ]; then
    echo -e "${RED}Error: Name required${NC}"
    echo "Usage: /prologue inbox <name>"
    exit 1
fi

PROLOGUE_DIR="$PROJECT_ROOT/.prologue"
INBOX_DIR="$PROLOGUE_DIR/_inbox"

mkdir -p "$INBOX_DIR"

SLUG=$(echo "$NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd 'a-z0-9-')
FILE="$INBOX_DIR/${SLUG}.md"

if [ -f "$FILE" ]; then
    echo -e "${YELLOW}Idea '$NAME' already exists${NC}"
    exit 1
fi

sed -e "s/\${NAME}/$NAME/g" \
    -e "s/\${TIMESTAMP}/$TIMESTAMP/g" \
    "$TEMPLATE_DIR/inbox.md" > "$FILE"

echo -e "${GREEN}Created idea: $NAME${NC}"
echo "  $FILE"

"$SCRIPT_DIR/update-index.sh" "$PROJECT_ROOT"
