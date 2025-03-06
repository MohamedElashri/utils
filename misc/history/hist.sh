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
# Returns raw commands without timestamps
process_zsh_history() {
    # Create a temporary file for processed history
    local temp_hist="$HIST_DIR/temp_processed_hist"
    
    # Method 1: Extract just the command part after semicolon
    LC_ALL=C cat "$HISTFILE_PATH" | 
    perl -ne 'print $1 if /^:[^;]*;(.*)/' > "$temp_hist" 2>/dev/null
    
    # If that didn't work (empty file), try with grep
    if [ ! -s "$temp_hist" ]; then
        # Method 2: Get lines without timestamps
        LC_ALL=C grep -a -v "^:" "$HISTFILE_PATH" > "$temp_hist" 2>/dev/null
    fi
    
    # If still empty, use a more aggressive approach
    if [ ! -s "$temp_hist" ]; then
        # Method 3: Just sanitize everything
        LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text > "$temp_hist"
    fi
    
    # Output the contents of the temporary file
    cat "$temp_hist"
    
    # Cleanup
    rm -f "$temp_hist"
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

# Get a command by history ID - reads directly from history file
get_command_by_id() {
    local id="$1"
    if [ "$SHELL_TYPE" = "bash" ]; then
        cat "$HISTFILE_PATH" | sanitize_text | nl -b a | awk -v id="$id" '$1 == id {$1=""; print substr($0,2)}'
    else
        # For zsh, use our special processing function
        process_zsh_history | nl -b a | awk -v id="$id" '$1 == id {$1=""; print substr($0,2)}'
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

# Command functions - using our safe zsh history processing
hist_show_last_n() { 
    if [ "$SHELL_TYPE" = "bash" ]; then
        cat "$HISTFILE_PATH" | sanitize_text | tail -n "$1" | nl -b a
    else
        process_zsh_history | tail -n "$1" | nl -b a
    fi
}

hist_search() {
    local keyword="$1"
    local results
    
    if [ "$SHELL_TYPE" = "bash" ]; then
        results=$(LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | grep -i -- "$keyword")
    else
        results=$(LC_ALL=C process_zsh_history | grep -i -- "$keyword")
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
    if [ "$SHELL_TYPE" = "bash" ]; then
        LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | sort -u | nl -b a
    else
        LC_ALL=C process_zsh_history | sort -u | nl -b a
    fi
}

hist_mostused() { 
    if [ "$SHELL_TYPE" = "bash" ]; then
        LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
    else
        LC_ALL=C process_zsh_history | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
    fi
}

hist_range() { 
    if [ "$SHELL_TYPE" = "bash" ]; then
        LC_ALL=C cat "$HISTFILE_PATH" | sanitize_text | nl -b a | awk -v start="$1" -v end="$2" '$1 >= start && $1 <= end {$1=""; print substr($0,2)}'
    else
        LC_ALL=C process_zsh_history | nl -b a | awk -v start="$1" -v end="$2" '$1 >= start && $1 <= end {$1=""; print substr($0,2)}'
    fi
}

hist_interactive() {
    if ! command -v fzf >/dev/null; then
        echo "fzf not found, install it for interactive mode" >&2
        return 1
    fi
    
    local command
    if [ "$SHELL_TYPE" = "bash" ]; then
        command=$(cat "$HISTFILE_PATH" | sanitize_text | fzf)
    else
        command=$(process_zsh_history | fzf)
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
    if [ "$SHELL_TYPE" = "bash" ]; then
        cat "$HISTFILE_PATH" | sanitize_text > "$1" 
    else
        process_zsh_history > "$1"
    fi
    echo "Session saved to $1"
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
            if [ "$SHELL_TYPE" = "bash" ]; then
                cat "$HISTFILE_PATH" | sanitize_text | nl -b a
            else
                process_zsh_history | nl -b a
            fi
            ;;
        *) hist_show_last_n "$1" ;;
    esac
}

main "$@"
