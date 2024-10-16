# SSH Tmux Automation Tool

This is a simple script that helps manage `tmux` sessions automatically when you connect to a server via SSH. It ensures that you always have a `tmux` session running, making it easier to maintain long-running tasks.

## Features
- Automatically attaches to or creates a new `tmux` session when connecting via SSH.
- Generates unique session names based on the client IP, port, and timestamp.
- Avoids creating sessions in VSCode SSH or existing `tmux` sessions.

## Installation
1. **Save the Script**:
   Save the following code into a file, for example `auto_tmux.sh`:
   ```bash
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
   ```

2. **Make the Script Executable**:
   Run the following command to make the script executable:
   ```bash
   chmod +x auto_tmux.sh
   ```

3. **Add to Your `.bashrc` or `.zshrc`**:
   To have this script run automatically when you SSH into a server, add the following line to your `.bashrc` or `.zshrc`:
   ```bash
   ~/path/to/auto_tmux.sh
   ```
   Replace `~/path/to/` with the actual path where the script is saved.

## Usage
Whenever you SSH into a server, the script will automatically run and attach you to an existing `tmux` session or create a new one with a unique name. This makes it easy to keep your work running even if the SSH connection is interrupted.

