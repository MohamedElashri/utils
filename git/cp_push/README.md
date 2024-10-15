# cp_push

`cp_push` is a script that automates the process of creating a new GitHub repository, initializing a local Git repository, committing your code, and pushing it to GitHub.

## Features

- **Repository Creation**: Automatically creates a new GitHub repository using the GitHub CLI (`gh`).
- **Initial Commit**: Commits the current state of your code with an initial commit message.
- **Privacy Options**: You can specify whether the repository should be public or private.
- **Automatic Push**: Pushes your code to the newly created GitHub repository.

## Installation

1. **Create the directory for the script in `$HOME/.local/bin`:**

    ```bash
    mkdir -p $HOME/.local/bin
    ```

2. **Download or create the script in `$HOME/.local/bin`:**

    Download the script directly:

    ```bash
    wget -O $HOME/.local/bin/cp_push https://github.com/MohamedElashri/utils/raw/refs/heads/main/git/cp_push/cp_push.sh
    ```

    Or create the script manually:

    ```bash
    nano $HOME/.local/bin/cp_push
    ```

    Paste the script content into the file and save it.

3. **Make the script executable:**

    ```bash
    chmod +x $HOME/.local/bin/cp_push
    ```

4. **Ensure `$HOME/.local/bin` is in your PATH:**

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
cp_push <repo-name> [--private]
```

### Options

- `<repo-name>`: **(Required)** The name of the new GitHub repository.
- `--private`: **(Optional)** Makes the repository private. By default, the repository is public.

### Examples

1. **Create and push to a public repository:**

    ```bash
    cp_push my-new-repo
    ```

2. **Create and push to a private repository:**

    ```bash
    cp_push my-new-repo --private
    ```

## Dependencies

This script depends on the following:

- **Git**: Ensure Git is installed on your system.
- **GitHub CLI (`gh`)**: Install the GitHub CLI to use this script. Use the following commands:

    For Linux:

    ```bash
    sudo apt install gh
    ```

    For macOS using Homebrew:

    ```bash
    brew install gh
    ```

    For Windows using `winget`:

    ```bash
    winget install GitHub.cli
    ```

> I didn’t test this for Windows because… who uses Windows in HEP?

