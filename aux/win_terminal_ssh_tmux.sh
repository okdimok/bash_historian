#!/bin/bash -i

# Get SSH hosts from config
SSH_HOSTS=$(grep "Host " ~/.ssh/config | sed "s/.*Host //" | sort)
mapfile -t hosts_array <<< "$SSH_HOSTS"

echo "╔════════════════════════════════════════╗"
echo "║      SSH Connection Manager            ║"
echo "╚════════════════════════════════════════╝"
echo

# Check if fzf is available for better TUI
if command -v fzf &> /dev/null; then
    user_host=$(printf '%s\n' "${hosts_array[@]}" | fzf \
        --height=60% \
        --border=rounded \
        --prompt="SSH Host ❯ " \
        --header="Type to filter | Enter to select | Esc to cancel" \
        --preview='echo "→ Connecting to: {}"' \
        --preview-window=up:2:wrap)

    if [ -z "$user_host" ]; then
        echo "No host selected. Exiting."
        exit 0
    fi
else
    # Display available hosts in columns
    echo "Available SSH hosts:"
    echo "────────────────────"
    printf '%s\n' "${hosts_array[@]}" | nl -w3 -s') ' | column -c 100
    echo
    echo "💡 Tip: Install 'fzf' for fuzzy search: sudo apt install fzf"
    echo

    # Set up tab completion for the read command
    # This creates a temporary completion function
    _ssh_hosts_completion() {
        local cur="${COMP_WORDS[COMP_CWORD]}"
        local hosts_list=$(printf '%s ' "${hosts_array[@]}")
        COMPREPLY=($(compgen -W "$hosts_list" -- "$cur"))
    }

    # Bind the completion function to readline (works with -i flag)
    complete -F _ssh_hosts_completion -o default read 2>/dev/null

    # Use read with readline editing enabled (-e flag enables tab completion)
    read -e -p "Enter hostname (Tab for completion) or number: " user_input

    # Remove the temporary completion
    complete -r read 2>/dev/null

    # Check if input is a number (for selecting by number)
    if [[ "$user_input" =~ ^[0-9]+$ ]]; then
        idx=$((user_input - 1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#hosts_array[@]} ]; then
            user_host="${hosts_array[$idx]}"
        else
            echo "❌ Invalid number. Exiting."
            exit 1
        fi
    else
        user_host="$user_input"
    fi

    if [ -z "$user_host" ]; then
        echo "No host provided. Exiting."
        exit 0
    fi
fi

# Connect
echo
echo "→ Connecting to: $user_host"
title "${user_host}"
ssh_tmux "${user_host}"