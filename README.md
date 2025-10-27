# Comprehensive Statusline for Claude Code

Feature-rich statusline with model, directory, git, session cost, thinking mode, and current mode.

```
Sonnet 4.5 │ ~/projects │ main ✓ │ $0.45/$15 │ 🧠 ON (⇥) │ 📋 PLAN (⇧⇥)
```

## Installation

**Step 1:** Add the marketplace and install
```bash
/plugin marketplace add anuragthakur77/claude-comprehensive-statusline
/plugin install comprehensive-statusline@comprehensive-statusline-marketplace
```

**Step 2:** Add this line to your `~/.claude/settings.json`:
```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ~/.claude/plugins/marketplaces/comprehensive-statusline-marketplace/statusline.sh"
  }
}
```

That's it! Restart Claude Code and the statusline will appear.

## Features

- Session cost tracking vs budget (color-coded: $0.45/$15)
- Git branch with clean/dirty status
- Thinking mode toggle (⇥)
- Current mode with switch shortcut (⇧⇥)
- Smart directory paths with ~ shorthand

## Note

Built-in mode indicator still appears. We've filed [issue #10406](https://github.com/anthropics/claude-code/issues/10406) to make it toggleable.

## License

Unlicense - Public Domain

**Author:** Anurag Thakur ([@anuragthakur77](https://github.com/anuragthakur77))
