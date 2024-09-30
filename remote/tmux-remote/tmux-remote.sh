# Check if we are on an SSH connection
if [ -n "$SSH_CONNECTION" ]; then
    # Check if this is not a VSCode SSH session
    if [ -z "$VSCODE_SSH_SESSION" ]; then
        # Check if tmux is not already running
        if [ -z "$TMUX" ]; then
            # Check if the session is interactive (terminal attached)
            if [ -t 1 ]; then
                # Extract client IP and port from SSH_CONNECTION
                client_ip=$(echo $SSH_CONNECTION | awk '{print $1}')
                client_port=$(echo $SSH_CONNECTION | awk '{print $2}')

                # Generate a unique session name using client IP, port, and current timestamp
                # Format: ssh_<client_ip>_<client_port>_<YYYYMMDDHHMMSS>
                timestamp=$(date "+%Y%m%d%H%M%S")
                session_name="ssh_${client_ip}_${client_port}_${timestamp}"

                # Start tmux session or attach to an existing one with the unique session name
                tmux attach-session -t "$session_name" || tmux new-session -s "$session_name"
                exit
            fi
        fi
    fi
fi
