
# Git Feature Branch Automation Script

This script automates the process of creating a new feature branch from the `main` or `master` branch, committing any changes, and optionally pushing the branch to the remote repository.

## Workflow

1. **Stashes Uncommitted Changes**: If there are uncommitted changes, the script stashes them.
2. **Creates a New Branch**: A new branch is created from the current branch.
3. **Applies Stashed Changes**: The stashed changes are applied to the new branch.
4. **Commits the Changes**: All changes are staged and committed with the provided commit message.
5. **Push (Optional)**: If the `--push` flag is set, the branch is pushed to the remote repository.


## Features

- **Automatic Branch Creation**: Stash changes, create a new branch, and apply changes.
- **Explicit Branch Name**: Requires the user to specify the new branch name using `--branch` or `-b`.
- **Explicit Commit Message**: Requires the user to specify the commit message using `--message` or `-m`.
- **Optional Push**: Pushes the new branch to the remote repository only when the `--push` or `-p` option is provided.
- **Help Option**: Provides a help message detailing usage with `--help` or `-h`.

## Installation

Follow these steps to install the script:

1. **Create the directory for the script:**

    ```bash
    mkdir -p ~/utils/git_feature
    ```

2. **Download or copy the script to the directory:**

    Download the script directly from here
    ``` bash
    wget https://github.com/MohamedElashri/utils/raw/refs/heads/main/git/git_feature/git_feature.sh
    ```
    
    Place the script in `~/utils/git_feature/`
   ```bash
   mv git_feature.sh ~/utils/git_feature/git_feature

    or use this command to create the file directly:

    ```bash
    nano ~/utils/git_feature/git_feature
    ```

    Then paste the script content and save the file.

4. **Make the script executable:**

    ```bash
    chmod +x ~/utils/git_feature/git_feature
    ```

5. **(Optional) Add the script to your PATH**:

    To make the script globally accessible from anywhere, you can add the following line to your `~/.bashrc` or `~/.zshrc`:

    ```bash
    echo 'export PATH="$HOME/utils/git_feature:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```

    For Zsh users:

    ```bash
    echo 'export PATH="$HOME/utils/git_feature:$PATH"' >> ~/.zshrc
    source ~/.zshrc
    ```

## Usage

```bash
git_feature [options]
```

### Options:

- `-b`, `--branch <branch_name>`: **(Required)** Specify the name of the new branch.
- `-m`, `--message <commit_message>`: **(Required)** Specify the commit message.
- `-p`, `--push`: **(Optional)** Push the branch to the remote repository.
- `-h`, `--help`: Display help message.

### Examples:

1. **Commit changes to a new branch without pushing:**
    ```bash
    git_feature --branch feature/new-feature --message "Add new feature work"
    ```

2. **Commit changes and push the new branch to the remote repository:**
    ```bash
    git_feature --branch feature/new-feature --message "Add new feature work" --push
    ```

3. **Display help message:**
    ```bash
    git_feature --help
    ```


