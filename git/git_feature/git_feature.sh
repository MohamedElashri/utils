#!/bin/bash

# Function to display help message
show_help() {
    echo "Usage: $0 [-p|--push] [-b|--branch <branch_name>] [-m|--message <commit_message>] [-c|--checkout-back]"
    echo ""
    echo "Options:"
    echo "  -p, --push            Push the branch to the remote repository"
    echo "  -b, --branch          Specify the new branch name"
    echo "  -m, --message         Specify the commit message"
    echo "  -c, --checkout-back   Checkout back to 'main' or 'master' after commit and push"
    echo "  -h, --help            Display this help message"
}

# Initialize variables
push_flag=false
checkout_flag=false
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
        -c | --checkout-back )
            checkout_flag=true
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

# Check if a branch name and commit message are provided
if [[ -z "$branch_name" || -z "$commit_message" ]]; then
    echo "Error: Branch name and commit message are required."
    show_help
    exit 1
fi

# Function to get the current branch name
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Function to check if a branch exists
branch_exists() {
    git show-ref --verify --quiet refs/heads/"$1"
    return $?
}

# Save the current branch
current_branch=$(get_current_branch)

# Check if the branch already exists
if branch_exists "$branch_name"; then
    echo "Branch '$branch_name' already exists. Checking it out..."
    git checkout "$branch_name" || { echo "Failed to checkout existing branch."; exit 1; }
else
    # Create a new branch
    git checkout -b "$branch_name" || { echo "Failed to create new branch."; exit 1; }
fi

# Stage all changes, including untracked files
git add --all || { echo "Failed to stage changes."; exit 1; }

# Check if there are any changes to commit
if git diff --cached --quiet; then
    echo "No changes to commit."
    exit 0
fi

# Commit the changes
git commit -m "$commit_message" || { echo "Failed to commit changes."; exit 1; }

# Push the branch if --push flag is provided
if [ "$push_flag" = true ]; then
    git push --set-upstream origin "$branch_name" || { echo "Failed to push to remote."; exit 1; }
    echo "Branch '$branch_name' successfully pushed to remote."
else
    echo "Branch '$branch_name' created and changes committed locally. Use '--push' to push the branch to the remote repository."
fi

# Checkout back to the original branch if --checkout-back flag is provided
if [ "$checkout_flag" = true ]; then
    git checkout "$current_branch" || { echo "Failed to checkout back to '$current_branch'."; exit 1; }
    echo "Checked out back to '$current_branch'."
fi
