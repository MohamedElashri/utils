history() {
    HIST_BACKUP_DIR="$HOME/.history/.history_backups"
    FAVORITES_FILE="$HOME/.history/.history_favorites"

    if [ "$#" -eq 0 ]; then
        # No arguments, display all history.
        builtin history
    elif [[ "$1" =~ ^[0-9]+$ ]]; then
        # If first argument is a number, show last n entries.
        builtin history | tail -n "$1"
    elif [ "$1" = "search" ] && [ "$#" -ge 2 ]; then
        # Search command. Usage: history search <keyword>
        shift
        builtin history | grep -i "$*"
    elif [ "$1" = "run" ] && [ "$#" -eq 2 ]; then
        # Run specific command by ID. Usage: history run <ID>
        command=$(builtin history | grep -E "^ *$2" | sed 's/^[0-9 ]*//')
        if [ -n "$command" ]; then
            eval "$command"
        else
            echo "Command ID not found in history."
        fi
    elif [ "$1" = "delete" ] && [ "$#" -eq 2 ]; then
        # Delete a specific command from history by ID. Usage: history delete <ID>
        history -d "$2"
        echo "Entry ID $2 deleted from history."
    elif [ "$1" = "clear" ]; then
        # Clear the entire history.
        builtin history -c
        echo "History cleared."
    elif [ "$1" = "unique" ]; then
        # Display unique commands. Usage: history unique
        builtin history | awk '{$1=""; print $0}' | sort | uniq
    elif [ "$1" = "export" ] && [ "$#" -eq 2 ]; then
        # Export history to a file. Usage: history export <filename>
        builtin history > "$2"
        echo "History exported to $2."
    elif [ "$1" = "import" ] && [ "$#" -eq 2 ]; then
        # Import history from a file. Usage: history import <filename>
        if [ -f "$2" ]; then
            cat "$2" | while read -r cmd; do
                history -s "$cmd"
            done
            echo "History imported from $2."
        else
            echo "File $2 not found."
        fi
    elif [ "$1" = "stats" ]; then
        # Show command usage statistics. Usage: history stats
        builtin history | awk '{$1=""; print $0}' | awk '{print $1}' | sort | uniq -c | sort -rn
    elif [ "$1" = "interactive" ]; then
        # Interactive search using fzf. Usage: history interactive
        if command -v fzf >/dev/null 2>&1; then
            cmd=$(builtin history | fzf | sed 's/^[0-9 ]*//')
            if [ -n "$cmd" ]; then
                eval "$cmd"
            fi
        else
            echo "fzf is not installed. Please install it for interactive search."
        fi
    elif [ "$1" = "range" ] && [ "$#" -eq 3 ]; then
        # Show history in a specified range. Usage: history range <start_ID> <end_ID>
        builtin history | awk -v start="$2" -v end="$3" '$1 >= start && $1 <= end'
    elif [ "$1" = "last" ]; then
        # Re-run the last command. Usage: history last
        command=$(builtin history | tail -n 2 | head -n 1 | sed 's/^[0-9 ]*//')
        if [ -n "$command" ]; then
            eval "$command"
        fi
    elif [ "$1" = "blacklist" ] && [ "$#" -eq 2 ]; then
        # Blacklist specific commands from being saved in history. Usage: history blacklist <command>
        export HISTIGNORE="$HISTIGNORE:$2"
        echo "Command '$2' is now blacklisted from history."
    elif [ "$1" = "favorite" ] && [ "$#" -eq 2 ]; then
        # Mark a command as favorite by ID. Usage: history favorite <ID>
        command=$(builtin history | grep -E "^ *$2" | sed 's/^[0-9 ]*//')
        if [ -n "$command" ]; then
            echo "$command" >> "$FAVORITES_FILE"
            echo "Command added to favorites."
        else
            echo "Command ID not found in history."
        fi
    elif [ "$1" = "showfavorites" ]; then
        # Show all favorite commands. Usage: history showfavorites
        if [ -f "$FAVORITES_FILE" ]; then
            cat "$FAVORITES_FILE"
        else
            echo "No favorites found."
        fi
    elif [ "$1" = "backup" ]; then
        # Backup history to a timestamped file. Usage: history backup
        mkdir -p "$HIST_BACKUP_DIR"
        backup_file="$HIST_BACKUP_DIR/history_backup_$(date +%Y%m%d_%H%M%S).txt"
        builtin history > "$backup_file"
        echo "History backed up to $backup_file."
    elif [ "$1" = "restorelast" ]; then
        # Restore the last deleted command. Usage: history restorelast
        last_deleted=$(tail -n 1 ~/.bash_history_deleted)
        if [ -n "$last_deleted" ]; then
            history -s "$last_deleted"
            echo "Restored: $last_deleted"
        else
            echo "No deleted command to restore."
        fi
    elif [ "$1" = "mostused" ]; then
        # Show the most frequently used commands. Usage: history mostused
        builtin history | awk '{$1=""; print $0}' | awk '{print $1}' | sort | uniq -c | sort -rn | head -10
    elif [ "$1" = "savesession" ]; then
        # Save current session history to a custom file. Usage: history savesession <filename>
        history -w "$2"
        echo "Current session history saved to $2."
    elif [ "$1" = "restoresession" ]; then
        # Restore session history from a custom file. Usage: history restoresession <filename>
        if [ -f "$2" ]; then
            history -r "$2"
            echo "Session history restored from $2."
        else
            echo "File $2 not found."
        fi
    else
        # Default case: if no match, pass all arguments to the builtin history command.
        builtin history "$@"
    fi
}
