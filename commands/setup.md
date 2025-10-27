# Setup Comprehensive Statusline

Configures the comprehensive statusline for your Claude Code session.

Run this command once after installing the plugin to activate the statusline.

---

```bash
#!/bin/bash

PLUGIN_DIR="${CLAUDE_PLUGIN_ROOT}"
SETTINGS_FILE="$HOME/.claude/settings.json"

# Check if settings file exists
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Add or update statusLine configuration
TEMP_FILE=$(mktemp)
jq ". + {\"statusLine\": {\"type\": \"command\", \"command\": \"bash $PLUGIN_DIR/statusline.sh\"}}" "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"

echo "✅ Statusline configured successfully!"
echo ""
echo "Your statusline will display:"
echo "  • Model name (e.g., Sonnet 4.5)"
echo "  • Current directory"
echo "  • Git branch and status"
echo "  • Session cost vs budget (\$0.45/\$15)"
echo "  • Thinking mode (🧠 ON/OFF)"
echo "  • Current mode (PLAN/NORMAL/AUTO EDIT)"
```
