#!/bin/bash

# Auto-configure statusline on plugin load
# CLAUDE_PLUGIN_ROOT is provided by Claude Code and points to the plugin directory
SETTINGS_FILE="$HOME/.claude/settings.json"

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Only add statusLine config if not already present
if ! grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
    # Add statusLine configuration using CLAUDE_PLUGIN_ROOT
    TEMP_FILE=$(mktemp)
    jq ". + {\"statusLine\": {\"type\": \"command\", \"command\": \"bash ${CLAUDE_PLUGIN_ROOT}/statusline.sh\"}}" "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"
fi
