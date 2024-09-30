#!/bin/bash

# Function to create and push a new GitHub repository
create_and_push_repo() {
    # Check if GitHub CLI is installed
    if ! command -v gh &> /dev/null
    then
        echo "Error: GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi

    # Check if repository name is provided
    if [ -z "$1" ]; then
        echo "Usage: cp_push.sh <repo-name> [--private]"
        exit 1
    fi

    # Set repository name and privacy flag
    REPO_NAME=$1
    PRIVACY_FLAG="--public"

    if [ "$2" = "--private" ]; then
        PRIVACY_FLAG="--private"
    fi

    # Initialize a new Git repository
    if ! git init; then
        echo "Error: Failed to initialize git repository."
        exit 1
    fi

    # Add all files to git
    if ! git add .; then
        echo "Error: Failed to add files to git repository."
        exit 1
    fi

    # Commit the added files
    if ! git commit -m "Initial commit"; then
        echo "Error: Failed to commit files."
        exit 1
    fi

    # Create the GitHub repository and push to it
    if ! gh repo create "$REPO_NAME" $PRIVACY_FLAG --disable-wiki --disable-issues --source=. --remote=origin --push; then
        echo "Error: Failed to create GitHub repository and push files."
        exit 1
    fi

    echo "Repository $REPO_NAME created and pushed successfully!"
}

# Call the function with the passed arguments
create_and_push_repo "$1" "$2"
