# Conventional Commit Message Generator
Interactive bash script to generate standardized commit messages following the Conventional Commits format.

## Installation

### Basic Installation
```bash
curl -o commit_msg https://github.com/MohamedElashri/utils/raw/refs/heads/main/dev/commit_msg/commit_msg
chmod +x commit_msg
```

### Propoer Installation

1. Create local bin directory if it doesn't exist:
```bash
mkdir -p ~/.local/bin
```

2. Move script to local bin:
```bash
mv commit_msg ~/.local/bin/
```

3. Add to shell configuration:

For Bash (~/.bashrc):
```bash
# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
```

For Zsh (~/.zshrc):
```bash
# Add local bin to PATH
export PATH="$HOME/.local/bin:$PATH"
```

4. Reload shell configuration:

For Bash:
```bash
source ~/.bashrc
```

For Zsh:
```bash
source ~/.zshrc
```

## Usage
```bash
commit_msg
```

You can now run `commit_msg` from any directory to generate your conventional commit messages.
