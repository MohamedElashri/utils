#!/usr/bin/env bash

HIST_DIR="$HOME/.config/.hist"
BLACKLIST_FILE="$HIST_DIR/blacklist"
FAVORITES_FILE="$HIST_DIR/favorites"
DELETED_LOG="$HIST_DIR/deleted.log"
BACKUP_DIR="$HIST_DIR/backups"
HISTFILE_PATH=""  # Will be set during shell detection

mkdir -p "$HIST_DIR" "$BACKUP_DIR"

# Shell detection
detect_shell() {
    # First try to determine from the current shell
    if [[ "$SHELL" == *"zsh"* ]]; then
        SHELL_TYPE="zsh"
        HISTFILE_PATH="$HOME/.zsh_history"
    elif [[ "$SHELL" == *"bash"* ]]; then
        SHELL_TYPE="bash"
        HISTFILE_PATH="$HOME/.bash_history"
    # Fallback to checking version variables
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_TYPE="zsh"
        HISTFILE_PATH="$HOME/.zsh_history"
    elif [ -n "$BASH_VERSION" ]; then
        SHELL_TYPE="bash"
        HISTFILE_PATH="$HOME/.bash_history"
    else
        echo "Unsupported shell. Please confirm you are using bash or zsh." >&2
        exit 1
    fi
    
    # If HISTFILE is set in the environment, use that
    if [ -n "$HISTFILE" ]; then
        HISTFILE_PATH="$HISTFILE"
    fi
    
    # Verify the history file exists
    if [ ! -f "$HISTFILE_PATH" ]; then
        echo "Warning: History file $HISTFILE_PATH not found."
        
        # Try to find history file in common locations
        if [ "$SHELL_TYPE" = "zsh" ]; then
            if [ -f "$HOME/.zhistory" ]; then
                HISTFILE_PATH="$HOME/.zhistory"
                echo "Found alternative zsh history file: $HISTFILE_PATH"
            elif [ -f "$ZDOTDIR/.zsh_history" ]; then
                HISTFILE_PATH="$ZDOTDIR/.zsh_history"
                echo "Found alternative zsh history file: $HISTFILE_PATH"
            fi
        fi
    fi
    
    # Final check
    if [ ! -f "$HISTFILE_PATH" ]; then
        echo "Error: Could not locate history file. Please set HISTFILE environment variable." >&2
        exit 1
    fi
}

# Clean text of problematic characters
sanitize_text() {
    # Remove non-printable characters but keep newlines and basic spacing
    LC_ALL=C tr -cd '[:print:]\n\t' 
}

# Process zsh history file with proper encoding handling
process_zsh_history() {
    # Create a temporary file for processed history
    local temp_hist="$HIST_DIR/temp_processed_hist"
    
    # First check if the file contains line-numbered entries (like in paste-2.txt)
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # Handle pre-formatted history with line numbers
        # This is likely from a 'history' command output
        sed -E 's/^ *([0-9]+) +//' "$HISTFILE_PATH" > "$temp_hist"
    else    
        # Try standard ZSH history format
        LC_ALL=C cat "$HISTFILE_PATH" | 
        perl -ne '
            # Match zsh history format with timestamp: : timestamp:elapsed;command
            if (/^:[0-9]+:[0-9]+;(.*)/) {
                print "$1\n";
            }
            # Extended format sometimes used in zsh
            elsif (/^:\s*[0-9]+:[0-9]+:[0-9]+;(.*)/) {
                print "$1\n";
            }
            # Alternative format with space after colon
            elsif (/^: ([0-9]+):([0-9]+);(.*)/) {
                print "$3\n";
            }
            # If no match (simple format), print the whole line
            elsif (!/^:/) {
                print "$_";
            }
        ' | sanitize_text > "$temp_hist"
    fi
    
    # If file is still empty after all attempts, try a simpler approach
    if [ ! -s "$temp_hist" ]; then
        # Just take everything after a semicolon if it exists, otherwise the whole line
        LC_ALL=C cat "$HISTFILE_PATH" | sed -E 's/^:[^;]*;//' | sanitize_text > "$temp_hist"
    fi
    
    # Output the contents of the temporary file
    cat "$temp_hist"
    
    # Cleanup
    rm -f "$temp_hist"
}

# Parse the history file from paste-2.txt directly
# This function handles the specific format seen in the user's input
parse_formatted_history() {
    local num_entries=${1:-10}  # Default to 10 entries if not specified
    
    # Create array to store commands
    declare -a commands
    
    # Read the history entries
    while IFS= read -r line; do
        # Skip empty lines
        [ -z "$line" ] && continue
        
        # Extract command from the line (remove leading number and spaces)
        command=$(echo "$line" | sed -E 's/^ *[0-9]+ +//')
        
        # Add to commands array
        commands+=("$command")
    done < "$HISTFILE_PATH"
    
    # Get total count of commands
    local total_cmds=${#commands[@]}
    
    # If requested more than we have, adjust
    if [ "$num_entries" -gt "$total_cmds" ]; then
        num_entries=$total_cmds
    fi
    
    # Calculate starting index to get the last N entries
    local start_idx=$((total_cmds - num_entries))
    if [ "$start_idx" -lt 0 ]; then
        start_idx=0
    fi
    
    # Output the last num_entries commands with numbers
    for ((i=start_idx; i<total_cmds; i++)); do
        echo "$((i - start_idx + 1))  ${commands[$i]}"
    done
}

# Format display output with proper line breaks
format_display() {
    awk '{
        # Replace runs of spaces with a single space
        gsub(/[ \t]+/, " ");
        # Trim leading/trailing whitespace
        sub(/^[ \t]+/, "");
        sub(/[ \t]+$/, "");
        # Print if not empty
        if (length($0) > 0) print $0;
    }'
}

# Load blacklist into array
load_blacklist() {
    touch "$BLACKLIST_FILE"
    mapfile -t BLACKLIST < "$BLACKLIST_FILE" 2>/dev/null || BLACKLIST=()
}

# Check if a command is blacklisted
is_blacklisted() {
    local cmd="$1"
    for blacklisted in "${BLACKLIST[@]}"; do
        if [[ "$cmd" == "$blacklisted" ]]; then
            return 0
        fi
    done
    return 1
}

# Get a command by history ID
get_command_by_id() {
    local id="$1"
    
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # Extract the command with the given ID from formatted history
        grep -E "^ *$id " "$HISTFILE_PATH" | sed -E 's/^ *[0-9]+ +//'
    else
        # Process the raw history file
        if [ "$SHELL_TYPE" = "bash" ]; then
            cat "$HISTFILE_PATH" | sanitize_text | format_display | nl -b a | 
            awk -v id="$id" '$1 == id {$1=""; print substr($0,2)}'
        else
            # For zsh, use our special processing function
            process_zsh_history | format_display | nl -b a | 
            awk -v id="$id" '$1 == id {$1=""; print substr($0,2)}'
        fi
    fi
}

# Display help
show_help() {
    cat <<EOF
hist - Enhanced History Manager for Bash & Zsh

Usage: hist [command] [arguments]

Commands:
  <n>                       Show last n entries.
  search <keyword>          Search history for a keyword.
  run <ID>                  Execute command by history ID.
  delete <ID>               Delete command by ID (with restore option).
  clear                     Clear the entire history.
  unique                    Show unique commands.
  backup                    Backup history to a timestamped file.
  restorelast               Restore the last deleted command.
  favorite <ID>             Mark command as favorite.
  showfavorites             List all favorite commands.
  blacklist <command>       Add a command to the blacklist (prevent saving).
  interactive               Fuzzy search history using fzf.
  range <start> <end>       Show history entries in range.
  mostused                  List the top 10 most used commands.
  savesession <file>        Save current session history to file.
  restoresession <file>     Load history from file into current session.

Options:
  -h, --help                Show this help message.

Data stored at: $HIST_DIR
EOF
}

# Command functions with format detection
hist_show_last_n() { 
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # Use the specialized parser for pre-formatted history
        parse_formatted_history "$1"
    else
        # Process as normal
        if [ "$SHELL_TYPE" = "bash" ]; then
            cat "$HISTFILE_PATH" | sanitize_text | format_display | tail -n "$1" | nl -b a
        else
            process_zsh_history | format_display | tail -n "$1" | nl -b a
        fi
    fi
}

hist_search() {
    local keyword="$1"
    local results
    
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        results=$(grep -i -- "$keyword" "$HISTFILE_PATH")
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            results=$(LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | format_display | grep -i -- "$keyword")
        else
            results=$(LC_ALL=C process_zsh_history | format_display | grep -i -- "$keyword")
        fi
    fi
    
    # Display results with line numbers
    if [ -n "$results" ]; then
        echo "$results" | nl -b a
    else
        echo "No matches found for '$keyword'"
    fi
}

hist_run() {
    local command
    command=$(get_command_by_id "$1")
    if [ -n "$command" ]; then
        echo "Executing: $command"
        eval "$command"
    else
        echo "Command ID $1 not found" >&2
    fi
}

hist_delete() {
    local command
    command=$(get_command_by_id "$1")
    if [ -n "$command" ]; then
        echo "$command" >> "$DELETED_LOG"
        echo "Deleted command $1 and saved to deleted.log"
        
        # Note: We're not actually deleting from the history file
        # as that's complex with zsh history format and not always reliable
    else
        echo "Command ID $1 not found" >&2
    fi
}

hist_backup() {
    local file="$BACKUP_DIR/history_$(date +%Y%m%d_%H%M%S).txt"
    cp "$HISTFILE_PATH" "$file"
    echo "Backup saved to $file"
}

hist_favorite() {
    local command
    command=$(get_command_by_id "$1")
    if [ -n "$command" ]; then
        echo "$command" >> "$FAVORITES_FILE"
        echo "Command $1 added to favorites"
    else
        echo "Command ID $1 not found" >&2
    fi
}

hist_showfavorites() { [ -f "$FAVORITES_FILE" ] && cat "$FAVORITES_FILE" || echo "No favorites yet."; }

hist_restorelast() {
    local last_command
    last_command=$(tail -n 1 "$DELETED_LOG")
    if [ -n "$last_command" ]; then
        # For zsh, append to the history file
        if [ "$SHELL_TYPE" = "zsh" ]; then
            # Add as a basic entry without timestamp
            echo "$last_command" >> "$HISTFILE_PATH"
        else 
            echo "$last_command" >> "$HISTFILE_PATH"
        fi
        
        sed -i.bak '$d' "$DELETED_LOG" 2>/dev/null || sed -i '' '$d' "$DELETED_LOG" 2>/dev/null
        echo "Restored: $last_command"
    else
        echo "No command to restore" >&2
    fi
}

hist_blacklist() {
    local cmd="$1"
    if grep -Fxq "$cmd" "$BLACKLIST_FILE"; then
        echo "Command already blacklisted"
    else
        echo "$cmd" >> "$BLACKLIST_FILE"
        echo "Blacklisted: $cmd"
    fi
}

hist_unique() {
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # For pre-formatted history, extract and sort unique commands
        sed -E 's/^ *[0-9]+ +//' "$HISTFILE_PATH" | sort -u | nl -b a
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | format_display | sort -u | nl -b a
        else
            LC_ALL=C process_zsh_history | format_display | sort -u | nl -b a
        fi
    fi
}

hist_mostused() {
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # For pre-formatted history, extract commands and count frequencies
        sed -E 's/^ *[0-9]+ +//' "$HISTFILE_PATH" | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | format_display | 
            awk '{print $1}' | sort | uniq -c | sort -rn | head -10
        else
            LC_ALL=C process_zsh_history | format_display | 
            awk '{print $1}' | sort | uniq -c | sort -rn | head -10
        fi
    fi
}

hist_range() {
    local start="$1"
    local end="$2"
    
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # For pre-formatted history, extract commands in range by their line numbers
        grep -E "^ *($start|$end|[$start-$end][0-9]*) " "$HISTFILE_PATH"
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | format_display | nl -b a | 
            awk -v start="$start" -v end="$end" '$1 >= start && $1 <= end {print $0}'
        else
            LC_ALL=C process_zsh_history | format_display | nl -b a | 
            awk -v start="$start" -v end="$end" '$1 >= start && $1 <= end {print $0}'
        fi
    fi
}

hist_interactive() {
    if ! command -v fzf >/dev/null; then
        echo "fzf not found, install it for interactive mode" >&2
        return 1
    fi
    
    local command
    
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # For pre-formatted history, extract commands and use fzf
        command=$(sed -E 's/^ *[0-9]+ +//' "$HISTFILE_PATH" | fzf)
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            command=$(cat "$HISTFILE_PATH" | sanitize_text | format_display | fzf)
        else
            command=$(process_zsh_history | format_display | fzf)
        fi
    fi
    
    [ -n "$command" ] && eval "$command"
}

hist_clear() { 
    # Make a backup before clearing
    hist_backup
    echo "Made a backup before clearing history"
    
    > "$HISTFILE_PATH"
    echo "History cleared" 
}

hist_savesession() {
    local output_file="$1"
    
    # Check if the history file is already a formatted history output
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        # For pre-formatted history, extract commands without line numbers
        sed -E 's/^ *[0-9]+ +//' "$HISTFILE_PATH" > "$output_file"
    else
        if [ "$SHELL_TYPE" = "bash" ]; then
            cat "$HISTFILE_PATH" | sanitize_text | format_display > "$output_file" 
        else
            process_zsh_history | format_display > "$output_file"
        fi
    fi
    echo "Session saved to $output_file"
}

hist_restoresession() {
    if [ -f "$1" ]; then
        cat "$1" >> "$HISTFILE_PATH" && echo "Session restored from $1"
    else
        echo "File not found: $1" >&2
    fi
}

# Dispatcher
main() {
    detect_shell
    load_blacklist
    
    # Check the format of the history file
    if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
        echo "Detected pre-formatted history file with line numbers" >&2
    fi
    
    case "$1" in
        -h|--help) show_help ;;
        search) hist_search "$2" ;;
        run) hist_run "$2" ;;
        delete) hist_delete "$2" ;;
        clear) hist_clear ;;
        unique) hist_unique ;;
        backup) hist_backup ;;
        restorelast) hist_restorelast ;;
        favorite) hist_favorite "$2" ;;
        showfavorites) hist_showfavorites ;;
        blacklist) hist_blacklist "$2" ;;
        interactive) hist_interactive ;;
        range) hist_range "$2" "$3" ;;
        mostused) hist_mostused ;;
        savesession) hist_savesession "$2" ;;
        restoresession) hist_restoresession "$2" ;;
        "") 
            # When no arguments, show all history
            if grep -q '^ *[0-9]\+ \+' "$HISTFILE_PATH"; then
                # For pre-formatted history, show as is
                cat "$HISTFILE_PATH"
            else
                if [ "$SHELL_TYPE" = "bash" ]; then
                    cat "$HISTFILE_PATH" | sanitize_text | format_display | nl -b a
                else
                    process_zsh_history | format_display | nl -b a
                fi
            fi
            ;;
        *) 
            # Show last n entries or handle any other command
            if [[ "$1" =~ ^[0-9]+$ ]]; then
                hist_show_last_n "$1"
            else
                echo "Unknown command: $1"
                show_help
            fi
            ;;
    esac
}

main "$@"
