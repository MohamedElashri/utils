#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CERN_USER="${USER}"
CERN_HOST="lxplus.cern.ch"
CERN_PATH=""
UNIVERSITY_USER="${USER}"
UNIVERSITY_HOST=""
UNIVERSITY_PATH=""
LOCAL_TEMP_DIR="./transfer_temp"
FILE_PATTERN="*.root"
DRY_RUN=false

# Function to print usage
print_usage() {
    echo -e "${BLUE}Usage:${NC}"
    echo -e "  $0 [OPTIONS] --source PATH --dest PATH --server HOST"
    echo
    echo -e "${BLUE}Required arguments:${NC}"
    echo -e "  --source PATH       Source path on CERN server (e.g., /eos/lhcb/...)"
    echo -e "  --dest PATH         Destination path on university server"
    echo -e "  --server HOST       University server hostname or SSH config name"
    echo
    echo -e "${BLUE}Optional arguments:${NC}"
    echo -e "  -h, --help          Show this help message"
    echo -e "  -d, --dry-run       Perform a dry run (no actual transfers)"
    echo -e "  --cern-user USER    CERN username (default: $CERN_USER)"
    echo -e "  --cern-host HOST    CERN host (default: $CERN_HOST)"
    echo -e "  --uni-user USER     University username (default: $UNIVERSITY_USER)"
    echo -e "  --temp-dir PATH     Local temporary directory (default: $LOCAL_TEMP_DIR)"
    echo -e "  --pattern PATTERN   File pattern to transfer (default: $FILE_PATTERN)"
    echo
}

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --source)
            CERN_PATH="$2"
            shift 2
            ;;
        --dest)
            UNIVERSITY_PATH="$2"
            shift 2
            ;;
        --server)
            UNIVERSITY_HOST="$2"
            shift 2
            ;;
        --cern-user)
            CERN_USER="$2"
            shift 2
            ;;
        --cern-host)
            CERN_HOST="$2"
            shift 2
            ;;
        --uni-user)
            UNIVERSITY_USER="$2"
            shift 2
            ;;
        --temp-dir)
            LOCAL_TEMP_DIR="$2"
            shift 2
            ;;
        --pattern)
            FILE_PATTERN="$2"
            shift 2
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo -e "${RED}Error: Unknown parameter: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Check for required arguments
if [ -z "$CERN_PATH" ] || [ -z "$UNIVERSITY_HOST" ] || [ -z "$UNIVERSITY_PATH" ]; then
    echo -e "${RED}Error: Missing required arguments${NC}"
    print_usage
    exit 1
fi

# Print banner
echo -e "${BLUE}======================================================================${NC}"
echo -e "${BLUE}  Generic Two-Step Transfer: CERN -> Local Machine -> Remote Server    ${NC}"
echo -e "${BLUE}======================================================================${NC}"

# Print configuration
echo -e "${GREEN}Configuration:${NC}"
echo -e "  CERN Host:       ${YELLOW}$CERN_USER@$CERN_HOST${NC}"
echo -e "  CERN Path:       ${YELLOW}$CERN_PATH${NC}"
echo -e "  University Host: ${YELLOW}$UNIVERSITY_HOST${NC}"
echo -e "  University Path: ${YELLOW}$UNIVERSITY_PATH${NC}"
echo -e "  Local Temp Dir:  ${YELLOW}$LOCAL_TEMP_DIR${NC}"
echo -e "  File Pattern:    ${YELLOW}$FILE_PATTERN${NC}"
echo -e "  Dry Run:         ${YELLOW}$DRY_RUN${NC}"
echo

# Confirm configuration
if [ "$DRY_RUN" = false ]; then
    read -p "Do you want to proceed with this configuration? (y/n): " CONFIRM
    if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Transfer canceled by user.${NC}"
        exit 0
    fi
fi

# Create local temp directory
echo -e "${GREEN}Creating local temporary directory...${NC}"
if [ "$DRY_RUN" = false ]; then
    mkdir -p "$LOCAL_TEMP_DIR"
else
    echo -e "${YELLOW}[DRY RUN] Would create: $LOCAL_TEMP_DIR${NC}"
fi

# Step 1: Download files from CERN to local machine
echo -e "${GREEN}Step 1: Downloading files from CERN to local machine...${NC}"
if [ "$DRY_RUN" = false ]; then
    rsync -av --include="$FILE_PATTERN" --include="*/" --exclude="*" \
        "$CERN_USER@$CERN_HOST:$CERN_PATH/" "$LOCAL_TEMP_DIR/"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to download files from CERN${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[DRY RUN] Would run: rsync -av --include=\"$FILE_PATTERN\" --include=\"*/\" --exclude=\"*\" $CERN_USER@$CERN_HOST:$CERN_PATH/ $LOCAL_TEMP_DIR/${NC}"
fi

# Check if we got any files
if [ "$DRY_RUN" = false ]; then
    FILE_COUNT=$(find "$LOCAL_TEMP_DIR" -type f -name "$FILE_PATTERN" | wc -l)
    if [ "$FILE_COUNT" -eq 0 ]; then
        echo -e "${YELLOW}Warning: No files matching pattern '$FILE_PATTERN' were found.${NC}"
        read -p "Do you want to continue with the transfer? (y/n): " CONTINUE
        if [[ ! "$CONTINUE" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Transfer canceled by user.${NC}"
            exit 0
        fi
    else
        echo -e "${GREEN}Found $FILE_COUNT files matching pattern '$FILE_PATTERN'.${NC}"
    fi
fi

# Step 2: Upload files from local machine to university
echo -e "${GREEN}Step 2: Uploading files from local machine to remote server...${NC}"
if [ "$DRY_RUN" = false ]; then
    # First ensure the target directory exists on the university server
    UNIVERSITY_CONNECTION="$UNIVERSITY_HOST"
    if [ -n "$UNIVERSITY_USER" ] && [ "$UNIVERSITY_USER" != "$USER" ]; then
        UNIVERSITY_CONNECTION="$UNIVERSITY_USER@$UNIVERSITY_HOST"
    fi
    
    ssh "$UNIVERSITY_CONNECTION" "mkdir -p $UNIVERSITY_PATH"
    
    # Then upload the files
    rsync -av "$LOCAL_TEMP_DIR/" "$UNIVERSITY_CONNECTION:$UNIVERSITY_PATH/"
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to upload files to university server${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[DRY RUN] Would run: ssh $UNIVERSITY_CONNECTION \"mkdir -p $UNIVERSITY_PATH\"${NC}"
    echo -e "${YELLOW}[DRY RUN] Would run: rsync -av $LOCAL_TEMP_DIR/ $UNIVERSITY_CONNECTION:$UNIVERSITY_PATH/${NC}"
fi

# Step 3: Clean up (optional)
echo -e "${GREEN}Step 3: Cleaning up local temporary files...${NC}"
if [ "$DRY_RUN" = false ]; then
    read -p "Do you want to remove the local temporary files? (y/n): " CLEANUP
    if [[ "$CLEANUP" =~ ^[Yy]$ ]]; then
        rm -rf "$LOCAL_TEMP_DIR"
        echo -e "${GREEN}Local temporary files removed.${NC}"
    else
        echo -e "${YELLOW}Local temporary files kept in: $LOCAL_TEMP_DIR${NC}"
    fi
else
    echo -e "${YELLOW}[DRY RUN] Would prompt to remove: $LOCAL_TEMP_DIR${NC}"
fi

echo -e "${GREEN}Transfer completed successfully!${NC}"
