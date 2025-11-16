#!/bin/bash

# Configuration
USER_AGENT="Mozilla/5.0 (X11; Linux x86_64; rv:145.0) Gecko/20100101 Firefox/145.0"
CLAUDE_CLI_PATH="${HOME}/.npm-global/lib/node_modules/@anthropic-ai/claude-code/cli.js"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Claude Code User-Agent Patcher"
echo "==============================="
echo ""

# Check if cli.js exists
if [ ! -f "$CLAUDE_CLI_PATH" ]; then
    echo -e "${RED}Error: Claude Code cli.js not found at $CLAUDE_CLI_PATH${NC}"
    echo "Please update CLAUDE_CLI_PATH in this script to match your installation."
    exit 1
fi

# Check if already patched
if grep -qF "User-Agent\",\"${USER_AGENT}\"" "$CLAUDE_CLI_PATH"; then
    echo -e "${GREEN}✓ Already patched! User-Agent is set to:${NC}"
    echo "  $USER_AGENT"
    exit 0
fi

# Check if this is the default axios user-agent pattern
if ! grep -q 'O\.set("User-Agent","axios\/' "$CLAUDE_CLI_PATH"; then
    echo -e "${YELLOW}Warning: Expected axios User-Agent pattern not found.${NC}"
    echo "The code may have changed. Manual inspection required."
    echo ""
    echo "Searching for User-Agent patterns:"
    grep -n "User-Agent" "$CLAUDE_CLI_PATH" | head -5
    exit 1
fi

# Create backup if it doesn't exist
BACKUP_PATH="${CLAUDE_CLI_PATH}.original"
if [ ! -f "$BACKUP_PATH" ]; then
    echo "Creating backup at ${BACKUP_PATH}..."
    cp "$CLAUDE_CLI_PATH" "$BACKUP_PATH"
    echo -e "${GREEN}✓ Backup created${NC}"
else
    echo -e "${YELLOW}Backup already exists at ${BACKUP_PATH}${NC}"
fi

# Apply the patch
echo ""
echo "Applying patch..."
sed -i "s|O\.set(\"User-Agent\",\"axios/\"+ml,!1)|O.set(\"User-Agent\",\"${USER_AGENT}\",!1)|g" "$CLAUDE_CLI_PATH"

# Verify the patch was applied
if grep -qF "User-Agent\",\"${USER_AGENT}\"" "$CLAUDE_CLI_PATH"; then
    echo -e "${GREEN}✓ Successfully patched!${NC}"
    echo ""
    echo "User-Agent is now set to:"
    echo "  $USER_AGENT"
    echo ""
    echo "To restore the original, run:"
    echo "  cp $BACKUP_PATH $CLAUDE_CLI_PATH"
else
    echo -e "${RED}✗ Patch failed!${NC}"
    echo "Restoring from backup..."
    cp "$BACKUP_PATH" "$CLAUDE_CLI_PATH"
    exit 1
fi
