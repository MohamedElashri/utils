#!/usr/bin/env bash

HIST_DIR="$HOME/.config/.hist"
BLACKLIST_FILE="$HIST_DIR/blacklist"
FAVORITES_FILE="$HIST_DIR/favorites"
DELETED_LOG="$HIST_DIR/deleted.log"
BACKUP_DIR="$HIST_DIR/backups"

mkdir -p "$HIST_DIR" "$BACKUP_DIR"

# Detect Shell Type
detect_shell() {
    if [ -n "$BASH_VERSION" ]; then
        SHELL_TYPE="bash"
        HIST_CMD="history"
    elif [ -n "$ZSH_VERSION" ]; then
        SHELL_TYPE="zsh"
        HIST_CMD="fc -l -n"
    else
        echo "Unsupported shell" >&2
        exit 1
    fi
}

# Load blacklist into array
load_blacklist() {
    touch "$BLACKLIST_FILE"
    mapfile -t BLACKLIST < "$BLACKLIST_FILE"
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
    if [ "$SHELL_TYPE" = "bash" ]; then
        HISTTIMEFORMAT= history | awk -v id="$id" '$1 == id { $1=""; print substr($0,2) }'
    else
        fc -l -n | awk -v id="$id" '$1 == id { $1=""; print substr($0,2) }'
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
  delete <ID>                Delete command by ID (with restore option).
  clear                      Clear the entire history.
  unique                     Show unique commands.
  backup                     Backup history to a timestamped file.
  restorelast                Restore the last deleted command.
  favorite <ID>              Mark command as favorite.
  showfavorites              List all favorite commands.
  blacklist <command>        Add a command to the blacklist (prevent saving).
  interactive                 Fuzzy search history using fzf.
  range <start> <end>        Show history entries in range.
  mostused                   List the top 10 most used commands.
  savesession <file>         Save current session history to file.
  restoresession <file>      Load history from file into current session.

Options:
  -h, --help                 Show this help message.

Data stored at: $HIST_DIR
EOF
}

# Command functions
hist_show_last_n() { $HIST_CMD | tail -n "$1"; }

hist_search() { $HIST_CMD | grep -i -- "$1"; }

hist_run() {
    local command
    command=$(get_command_by_id "$1")
    if [ -n "$command" ]; then
        builtin "$SHELL" -c "$command"
    else
        echo "Command ID $1 not found" >&2
    fi
}

hist_delete() {
    local command
    command=$(get_command_by_id "$1")
    if [ -n "$command" ]; then
        echo "$command" >> "$DELETED_LOG"
        history -d "$1"
        echo "Deleted command $1 and saved to deleted.log"
    else
        echo "Command ID $1 not found" >&2
    fi
}

hist_backup() {
    local file="$BACKUP_DIR/history_$(date +%Y%m%d_%H%M%S).txt"
    $HIST_CMD > "$file"
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
        history -s "$last_command"
        sed -i '' -e '$d' "$DELETED_LOG"
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

hist_unique() { $HIST_CMD | awk '{$1=""; print substr($0,2)}' | sort -u; }

hist_mostused() { $HIST_CMD | awk '{$1=""; print $0}' | awk '{print $1}' | sort | uniq -c | sort -rn | head -10; }

hist_range() { $HIST_CMD | awk -v start="$1" -v end="$2" '$1 >= start && $1 <= end'; }

hist_interactive() {
    if ! command -v fzf >/dev/null; then
        echo "fzf not found, install it for interactive mode" >&2
        return 1
    fi
    local command
    command=$($HIST_CMD | fzf | sed 's/^[0-9 ]*//')
    [ -n "$command" ] && builtin "$SHELL" -c "$command"
}

hist_clear() { history -c && echo "History cleared"; }

hist_savesession() { history -w "$1" && echo "Session saved to $1"; }

hist_restoresession() {
    if [ -f "$1" ]; then
        history -r "$1" && echo "Session restored from $1"
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
        "") $HIST_CMD ;;
        *) hist_show_last_n "$1" ;;
    esac
}

main "$@"
