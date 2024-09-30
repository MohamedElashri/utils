#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [-p|--push] -b|--branch <branch_name> -m|--message <commit_message>"
    echo ""
    echo "Options:"
    echo "  -p, --push            Push the branch to the remote repository"
    echo "  -b, --branch          Specify the new branch name"
    echo "  -m, --message         Specify the commit message"
    echo "  -h, --help            Display this help message"
}

# Initialize variables
push_flag=false
branch_name=""
commit_message=""

# Parse command-line arguments
while [[ "$1" != "" ]]; do
    case $1 in
        -p | --push )
            push_flag=true
            ;;
        -b | --branch )
            shift
            branch_name="$1"
            ;;
        -m | --message )
            shift
            commit_message="$1"
            ;;
        -h | --help )
            show_help
            exit 0
            ;;
        * )
            echo "Invalid option: $1"
            show_help
            exit 1
    esac
    shift
done

# Step 1: Check if a branch name and commit message are provided
if [[ -z "$branch_name" || -z "$commit_message" ]]; then
    echo "Error: Branch name and commit message are required."
    show_help
    exit 1
fi

# Step 2: Check for unstaged changes
if git diff --quiet && git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

# Step 3: Stash the changes
git stash -u || { echo "Failed to stash changes."; exit 1; }

# Step 4: Create a new branch
git checkout -b "$branch_name" || { echo "Failed to create new branch."; exit 1; }

# Step 5: Apply the stashed changes
git stash pop || { echo "Failed to apply stashed changes."; exit 1; }

# Step 6: Commit the changes
git add . || { echo "Failed to stage changes."; exit 1; }
git commit -m "$commit_message" || { echo "Failed to commit changes."; exit 1; }

# Step 7: Push the branch if --push flag is provided
if [ "$push_flag" = true ]; then
    git push origin "$branch_name" || { echo "Failed to push to remote."; exit 1; }
    echo "Branch '$branch_name' successfully pushed to remote."
else
    echo "Branch '$branch_name' created and changes committed locally. Use '--push' to push the branch to the remote repository."
fi

