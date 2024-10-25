#!/bin/bash

# Check if we are on an SSH connection, not a VSCode SSH session, and not inside an existing tmux session
if [ -n "$SSH_CONNECTION" ] && [ -z "$VSCODE_SSH_SESSION" ] && [ -z "$TMUX" ] && [ -t 1 ]; then
    # Extract client IP and port from SSH_CONNECTION
    read -r client_ip client_port _ <<< "$SSH_CONNECTION"

    # Generate a unique session name using client IP, port, and current timestamp
    timestamp=$(date "+%Y%m%d%H%M%S")
    session_name="ssh_${client_ip}_${client_port}_${timestamp}"

    # Start tmux session or attach to an existing one with the unique session name
    if ! tmux attach-session -t "$session_name" 2>/dev/null; then
        tmux new-session -s "$session_name"
    fi
    exit
fi
