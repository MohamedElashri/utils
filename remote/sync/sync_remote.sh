#!/bin/bash

# Define colors for logs
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No color

# Logging functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_debug() { [[ "$DEBUG" == true ]] && echo -e "${BLUE}[DEBUG]${NC} $1"; }

# Default values
SYNC_INTERVAL=10
DIRECTION="both"
DEBUG=false

# Help function
usage() {
    echo "Usage: $0 [OPTIONS] REMOTE_USER REMOTE_SERVER REMOTE_PATH LOCAL_PATH"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message and exit"
    echo "  -i, --interval N    Set the sync interval in seconds (default: 10)"
    echo "  -d, --direction DIR Set sync direction (options: both, local-to-remote, remote-to-local; default: both)"
    echo "  --debug             Enable debug output for troubleshooting"
    echo ""
    echo "Example:"
    echo "  $0 -i 5 -d remote-to-local user server:/remote/path /local/path"
}

# Parse options
while [[ "$1" != "" ]]; do
    case "$1" in
        -h | --help)
            usage
            exit 0
            ;;
        -i | --interval)
            shift
            SYNC_INTERVAL="$1"
            ;;
        -d | --direction)
            shift
            DIRECTION="$1"
            ;;
        --debug)
            DEBUG=true
            ;;
        *)
            if [[ -z "$REMOTE_USER" ]]; then
                REMOTE_USER="$1"
            elif [[ -z "$REMOTE_SERVER" ]]; then
                REMOTE_SERVER="$1"
            elif [[ -z "$REMOTE_PATH" ]]; then
                REMOTE_PATH="$1"
            elif [[ -z "$LOCAL_PATH" ]]; then
                LOCAL_PATH="$1"
            else
                log_error "Unexpected argument: $1"
                usage
                exit 1
            fi
            ;;
    esac
    shift
done

# Validate required arguments
if [[ -z "$REMOTE_USER" || -z "$REMOTE_SERVER" || -z "$REMOTE_PATH" || -z "$LOCAL_PATH" ]]; then
    log_error "Missing required arguments."
    usage
    exit 1
fi

# Validate sync interval
if ! [[ "$SYNC_INTERVAL" =~ ^[0-9]+$ ]]; then
    log_error "Sync interval must be a positive integer."
    exit 1
fi

# Ensure local path exists
if [ ! -d "$LOCAL_PATH" ]; then
    log_info "Local path '$LOCAL_PATH' does not exist. Creating it."
    mkdir -p "$LOCAL_PATH"
fi

# Function to generate a checksum file list in a directory
generate_checksum() {
    find "$1" -type f ! -path "*/node_modules/*" -exec md5sum {} + 2>/dev/null | sort | md5sum | awk '{print $1}'
}

# Sync functions
sync_local_to_remote() {
    log_info "Syncing changes from local to remote"
    log_debug "Executing rsync from '$LOCAL_PATH' to '${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}'"
    rsync -avz --exclude 'node_modules' "$LOCAL_PATH/" "${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}"
}

sync_remote_to_local() {
    log_info "Syncing changes from remote to local"
    log_debug "Executing rsync from '${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}' to '$LOCAL_PATH'"
    rsync -avz --exclude 'node_modules' "${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}/" "$LOCAL_PATH"
}

# Initial sync based on specified direction
log_info "Performing initial sync from ${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH} to ${LOCAL_PATH}"
case "$DIRECTION" in
    both)
        sync_remote_to_local
        sync_local_to_remote
        ;;
    local-to-remote)
        sync_local_to_remote
        ;;
    remote-to-local)
        sync_remote_to_local
        ;;
    *)
        log_error "Invalid direction option. Use 'both', 'local-to-remote', or 'remote-to-local'."
        exit 1
        ;;
esac

# Monitor changes and sync based on checksums
while true; do
    log_debug "Calculating local checksum for directory '$LOCAL_PATH'"
    local_checksum=$(generate_checksum "$LOCAL_PATH")

    log_debug "Calculating remote checksum for directory '${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_PATH}'"
    remote_checksum=$(ssh "$REMOTE_USER@$REMOTE_SERVER" "cd $REMOTE_PATH && find . -type f ! -path '*/node_modules/*' -exec md5sum {} + 2>/dev/null | sort | md5sum | awk '{print \$1}'")

    # Determine syncing action based on checksum differences and direction
    if [ "$DIRECTION" == "both" ] && [ "$local_checksum" != "$remote_checksum" ]; then
        log_info "Checksum mismatch detected. Syncing in both directions..."
        sync_remote_to_local
        sync_local_to_remote
    elif [ "$DIRECTION" == "local-to-remote" ] && [ "$local_checksum" != "$remote_checksum" ]; then
        log_info "Checksum mismatch detected. Syncing local changes to remote..."
        sync_local_to_remote
    elif [ "$DIRECTION" == "remote-to-local" ] && [ "$local_checksum" != "$remote_checksum" ]; then
        log_info "Checksum mismatch detected. Syncing remote changes to local..."
        sync_remote_to_local
    else
        log_debug "No checksum mismatch detected. No sync needed."
    fi

    # Wait before next check
    log_debug "Waiting $SYNC_INTERVAL seconds before the next sync check."
    sleep "$SYNC_INTERVAL"
done
