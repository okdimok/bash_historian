#!/bin/bash -i

# Get SSH hosts from config and all included config files
_ssh_config_files=("$HOME/.ssh/config")
while IFS= read -r inc_path; do
    # Expand ~ to $HOME
    inc_path="${inc_path/#\~/$HOME}"
    # Expand globs
    for f in $inc_path; do
        [ -f "$f" ] && _ssh_config_files+=("$f")
    done
done < <(grep -i '^Include ' "$HOME/.ssh/config" 2>/dev/null | sed 's/^Include[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')

SSH_HOSTS=$(grep -h "^Host " "${_ssh_config_files[@]}" 2>/dev/null | sed "s/^Host //" | tr ' ' '\n' | grep -v '[*?]' | sort -u)
mapfile -t hosts_array <<< "$SSH_HOSTS"

clear

# Source color definitions
source "$(dirname "$0")/../bash_colors"

echo -e "${Cyan}╔════════════════════════════════╗${Color_Off}"
echo -e "${Cyan}║${Color_Off}     ${BGreen}SSH Connection Manager${Color_Off}     ${Cyan}║${Color_Off}"
echo -e "${Cyan}╚════════════════════════════════╝${Color_Off}"
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
        echo -e "${BYellow}No host selected. Exiting.${Color_Off}"
        exit 0
    fi
else
    # Display available hosts in columns
    echo -e "${Blue}Available SSH hosts:${Color_Off}"
    echo -e "${Cyan}────────────────────${Color_Off}"
    printf '%s\n' "${hosts_array[@]}" | nl -w3 -s') ' | column -c 100
    echo
    echo -e "${BYellow}💡 Tip: Install 'fzf' for fuzzy search: ${Color_Off}sudo apt install fzf"
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
    echo -ne "${Green}Enter hostname ${Cyan}(Tab for completion)${Green} or number: ${Color_Off}"
    read -e user_input

    # Remove the temporary completion
    complete -r read 2>/dev/null

    # Check if input is a number (for selecting by number)
    if [[ "$user_input" =~ ^[0-9]+$ ]]; then
        idx=$((user_input - 1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#hosts_array[@]} ]; then
            user_host="${hosts_array[$idx]}"
        else
            echo -e "${Red}❌ Invalid number. Exiting.${Color_Off}"
            exit 1
        fi
    else
        user_host="$user_input"
    fi

    if [ -z "$user_host" ]; then
        echo -e "${BYellow}No host provided. Exiting.${Color_Off}"
        exit 0
    fi
fi

# Connect
echo
echo -e "${Green}→ Connecting to: ${BCyan}$user_host${Color_Off}"
title "${user_host}"
ssh_tmux "${user_host}"