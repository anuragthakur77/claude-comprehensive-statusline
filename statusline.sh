#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract available information from Claude Code JSON
model=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "~"')
exceeds_200k=$(echo "$input" | jq -r '.exceeds_200k_tokens // false')
transcript_path=$(echo "$input" | jq -r '.transcript_path // ""')

# Smart directory path display
if [ "$current_dir" = "$HOME" ]; then
    # In home directory
    dir_name="~"
elif [[ "$current_dir" == "$HOME"/* ]]; then
    # In a subdirectory of home
    relative_path="${current_dir#$HOME/}"
    # Get last 2 components if path has multiple levels
    component_count=$(echo "$relative_path" | tr '/' '\n' | wc -l)
    if [ "$component_count" -le 2 ]; then
        dir_name="~/$relative_path"
    else
        # Take last 2 components
        dir_name="~/$(echo "$relative_path" | rev | cut -d'/' -f1,2 | rev)"
    fi
else
    # Outside home directory - show last 2 components
    dir_name=$(echo "$current_dir" | rev | cut -d'/' -f1,2 | rev)
fi

# Parse REAL token usage from transcript JSONL file
token_info=""
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
    # Sum up all input_tokens and output_tokens from the transcript
    total_tokens=$(jq -s 'map(select(.message.usage != null) | .message.usage | (.input_tokens // 0) + (.output_tokens // 0)) | add // 0' "$transcript_path" 2>/dev/null)

    if [ -n "$total_tokens" ] && [ "$total_tokens" -gt 0 ]; then
        context_window=200000

        # Calculate percentage
        percentage=$(echo "scale=0; ($total_tokens * 100) / $context_window" | bc -l 2>/dev/null || echo "0")

        # Convert to K notation (thousands)
        # Divide by 1000 and round to 1 decimal if needed, otherwise whole number
        tokens_k=$(echo "scale=1; $total_tokens / 1000" | bc -l 2>/dev/null || echo "0")
        window_k=$(echo "scale=1; $context_window / 1000" | bc -l 2>/dev/null || echo "0")

        # Remove trailing .0 for whole numbers
        tokens_k=$(echo "$tokens_k" | sed 's/\.0$//')
        window_k=$(echo "$window_k" | sed 's/\.0$//')

        # Color code based on usage
        if [ "$percentage" -ge 80 ]; then
            token_color="\033[31m"  # red
        elif [ "$percentage" -ge 60 ]; then
            token_color="\033[33m"  # yellow
        else
            token_color="\033[32m"  # green
        fi

        token_info=$(printf " \033[35m│\033[0m %bT: %sK/%sK\033[0m" "$token_color" "$tokens_k" "$window_k")
    fi
fi

# Git information
git_info=""
if [ -d "$current_dir/.git" ] || git -C "$current_dir" rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git -C "$current_dir" --no-optional-locks rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        if git -C "$current_dir" --no-optional-locks diff --quiet 2>/dev/null && \
           git -C "$current_dir" --no-optional-locks diff --cached --quiet 2>/dev/null; then
            status_icon="✓"
            status_color="\033[32m"  # green
        else
            status_icon="✗"
            status_color="\033[31m"  # red
        fi
        git_info=$(printf " \033[35m│\033[0m \033[36m%s\033[0m %b%s\033[0m" "$branch" "$status_color" "$status_icon")
    fi
fi

# Warning if exceeds 200k tokens
warning_info=""
if [ "$exceeds_200k" = "true" ]; then
    warning_info=$(printf " \033[35m│\033[0m \033[31m⚠\033[0m")
fi

# Detect current mode from debug log
mode_info="\033[36m⇧⇥=Mode\033[0m"
session_id=$(echo "$input" | jq -r '.session_id // ""')
if [ -n "$session_id" ]; then
    debug_file="$HOME/.claude/debug/${session_id}.txt"
    if [ -f "$debug_file" ]; then
        # Find the last occurrence of "Setting mode to" and extract the mode value
        current_mode=$(grep "Setting mode to" "$debug_file" 2>/dev/null | tail -1 | grep -o "'[^']*'" | tr -d "'" || echo "")

        # Display based on mode
        case "$current_mode" in
            "plan")
                mode_info="\033[36m📋 PLAN (⇧⇥)\033[0m"
                ;;
            "acceptEdits")
                mode_info="\033[36m✓ AUTO EDIT (⇧⇥)\033[0m"
                ;;
            "default")
                mode_info="\033[36m✏️ NORMAL (⇧⇥)\033[0m"
                ;;
            *)
                mode_info="\033[36m⇧⇥=Mode\033[0m"
                ;;
        esac
    fi
fi

# Thinking mode indicator - always show with ON/OFF state
thinking_info=""
settings_file="$HOME/.claude/settings.json"
if [ -f "$settings_file" ]; then
    thinking_enabled=$(jq -r '.alwaysThinkingEnabled // false' "$settings_file" 2>/dev/null)
    if [ "$thinking_enabled" = "true" ]; then
        # ON state - yellow/blue color
        thinking_info=$(printf " \033[35m│\033[0m \033[33m🧠 ON\033[0m \033[36m(⇥ Tab)\033[0m \033[35m│\033[0m %b" "$mode_info")
    else
        # OFF state - green color
        thinking_info=$(printf " \033[35m│\033[0m \033[32m🧠 OFF\033[0m \033[36m(⇥ Tab)\033[0m \033[35m│\033[0m %b" "$mode_info")
    fi
else
    # Default to OFF if settings file not found
    thinking_info=$(printf " \033[35m│\033[0m \033[32m🧠 OFF\033[0m \033[36m(⇥ Tab)\033[0m \033[35m│\033[0m %b" "$mode_info")
fi

# Build and print the status line
printf "\033[1m\033[34m%s\033[0m \033[35m│\033[0m \033[32m%s\033[0m%b%b%b%b\n" "$model" "$dir_name" "$git_info" "$token_info" "$warning_info" "$thinking_info"
