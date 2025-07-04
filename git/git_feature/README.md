# Git Feature Branch Automation Script

This script automates the process of creating a new feature branch from the `main` or `master` branch, committing any changes, optionally pushing the branch to the remote repository, and (optionally) switching back to the `main` or `master` branch.

## Workflow

1. **Stashes Uncommitted Changes**: If there are uncommitted changes, the script stashes them.
2. **Creates a New Branch**: A new branch is created from the current branch.
3. **Applies Stashed Changes**: The stashed changes are applied to the new branch.
4. **Commits the Changes**: All changes are staged and committed with the provided commit message.
5. **Push (Optional)**: If the `--push` flag is set, the branch is pushed to the remote repository.
6. **Checkout Back (Optional)**: If the `--checkout-back` flag is set, the script checks out back to the `main` or `master` branch, depending on which one exists.


## Installation

Follow these steps to install the script:

1. **Create the directory for the script in `$HOME/.local/bin`:**

    ```bash
    mkdir -p $HOME/.local/bin
    ```

2. **Download or copy the script to `$HOME/.local/bin`:**

    Download the script directly:

    ```bash
    wget -O $HOME/.local/bin/git_feature https://github.com/MohamedElashri/utils/raw/refs/heads/main/git/git_feature/git_feature.sh && chmod +x $HOME/.local/bin/git_feature
    ```

    Or create the file directly with:

    ```bash
    nano $HOME/.local/bin/git_feature
    ```

    Then paste the script content into the file and save it.

   Then we need to give execusion permission

   ```bash
   chmod +x $HOME/.local/bin/git_feature
   ```

4. **Make the script executable:**

    ```bash
    chmod +x $HOME/.local/bin/git_feature
    ```

5. **Ensure `$HOME/.local/bin` is in your PATH:**

    Add the following line to your `~/.bashrc` or `~/.zshrc`:

    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    ```

    For Zsh users:

    ```bash
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
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
- `-c`, `--checkout-back`: **(Optional)** Checkout back to the `main` or `master` branch after committing.
- `-h`, `--help`: Display help message.

### Examples:

1. **Commit changes to a new branch without pushing, and return to `main`/`master`:**
    ```bash
    git_feature --branch feature/new-feature --message "Add new feature work" --checkout-back
    ```

2. **Commit changes, push the new branch, and return to `main`/`master`:**
    ```bash
    git_feature --branch feature/new-feature --message "Add new feature work" --push --checkout-back
    ```

3. **Display help message:**
    ```bash
    git_feature --help
    ```

