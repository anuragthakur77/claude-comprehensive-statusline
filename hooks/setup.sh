#!/bin/bash

# Auto-configure statusline on plugin load
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Only add statusLine config if not already present
if ! grep -q '"statusLine"' "$SETTINGS_FILE" 2>/dev/null; then
    # Add statusLine configuration
    TEMP_FILE=$(mktemp)
    jq ". + {\"statusLine\": {\"type\": \"command\", \"command\": \"bash $PLUGIN_DIR/statusline.sh\"}}" "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"
fi
