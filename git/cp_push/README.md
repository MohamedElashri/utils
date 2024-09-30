
# cp_push

`cp_push` is a script that automates the process of creating a new GitHub repository, initializing a local git repository, committing your code, and pushing it to GitHub.

## Features

- **Repository Creation**: Automatically creates a new GitHub repository using the GitHub CLI (`gh`).
- **Initial Commit**: Commits the current state of your code with an initial commit message.
- **Privacy Options**: You can specify whether the repository should be public or private.
- **Automatic Push**: Pushes your code to the newly created GitHub repository.

## Installation

1. **Download or clone the script**:

   Create the directory for the script and place it inside:
   ```bash
   mkdir -p ~/utils/cp_push
   ```

   Create the script file:
   ```bash
   nano ~/utils/cp_push/cp_push
   ```

   Paste the script content and save.

   Or download the script and mv it to the locations in one command

   ```bash
   wget -P ~/utils/cp_push https://github.com/MohamedElashri/utils/raw/refs/heads/main/git/cp_push/cp_push.sh
   ``` 

3. **Make the script executable**:
   ```bash
   chmod +x ~/utils/cp_push/cp_push
   ```

4. **(Optional) Add to PATH**:
   To make the script accessible globally from the terminal:
   
   ```bash
   echo 'export PATH="$HOME/utils/cp_push:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

   or for zsh

  ```bash
   echo 'export PATH="$HOME/utils/cp_push:$PATH"' >> ~/.zshrc
   source ~/.zshrc
   ```


## Usage

```bash
cp_push <repo-name> [--private]
```

### Options

- `<repo-name>`: **(Required)** The name of the new GitHub repository.
- `--private`: **(Optional)** Makes the repository private. By default, the repository is public.

### Example

1. **Create and push to a public repository**:
   ```bash
   cp_push my-new-repo
   ```

2. **Create and push to a private repository**:
   ```bash
   cp_push my-new-repo --private
   ```

## Dependencies

This script depends on the following:

- **Git**: Make sure git is installed on your system.
- **GitHub CLI (`gh`)**: Install the GitHub CLI to use this script. You can install it using the following commands:

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
I didn't test this for windows because who uses windows in HEP?
