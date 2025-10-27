# Install Comprehensive Statusline

Install and configure the comprehensive statusline for Claude Code.

This will:
1. Copy the statusline script to ~/.claude/statusline.sh
2. Update your ~/.claude/settings.json to use the statusline
3. Enable the comprehensive statusline display

## Features

The statusline displays:
- **Model name** - Current Claude model (e.g., Sonnet 4.5)
- **Directory** - Smart path with ~ shorthand
- **Git branch & status** - Branch name with ✓ (clean) or ✗ (dirty)
- **Token usage** - Real tokens from transcript (e.g., T: 100K/200K)
- **Thinking mode** - ON/OFF with toggle shortcut (⇥ Tab)
- **Current mode** - Plan/Normal/Auto Edit with switch shortcut (⇧⇥)

## Example

```
Sonnet 4.5 │ ~/projects/app │ main ✓ │ T: 45K/200K │ 🧠 ON (⇥ Tab) │ 📋 PLAN (⇧⇥)
```

---

```bash
#!/bin/bash

# Get the plugin directory
PLUGIN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "📦 Installing Comprehensive Statusline..."

# Copy statusline script
cp "$PLUGIN_DIR/statusline.sh" ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
echo "✅ Copied statusline script to ~/.claude/statusline.sh"

# Update settings.json
SETTINGS_FILE="$HOME/.claude/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo '{}' > "$SETTINGS_FILE"
fi

# Use jq to update settings
TEMP_FILE=$(mktemp)
jq '. + {"statusLine": {"type": "command", "command": "bash ~/.claude/statusline.sh"}}' "$SETTINGS_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$SETTINGS_FILE"

echo "✅ Updated ~/.claude/settings.json"
echo ""
echo "🎉 Installation complete!"
echo ""
echo "Your statusline will appear at the bottom of Claude Code and shows:"
echo "  • Model name"
echo "  • Current directory with smart paths"
echo "  • Git branch and status"
echo "  • Token usage (real-time from transcript)"
echo "  • Thinking mode status (⇥ Tab to toggle)"
echo "  • Current mode: Plan/Normal/Auto Edit (⇧⇥ to cycle)"
echo ""
echo "The statusline updates automatically as you work!"
```
