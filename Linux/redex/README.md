# Redex

**Redex** is a command wrapper script that executes commands and redirects all output (both stdout and stderr) to a log file. It provides comprehensive error handling, colorful logging, and is designed to work in both `bash` and `zsh` environments.

## Installation

To install **Redex**, simply clone the repository and move the script to your preferred location. By default, we assume it is installed at `~/.local/bin/redex`:

```sh
mkdir -p ~/.local/bin
cp redex ~/.local/bin/redex
chmod +x ~/.local/bin/redex
```

Ensure that `~/.local/bin` is included in your system's `PATH`. You can add the following line to your `~/.bashrc` or `~/.zshrc`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Reload your shell configuration:

```sh
source ~/.bashrc # or source ~/.zshrc
```

## Usage

To use **Redex**, you can pass any command you'd like to execute, and the script will log all output to a specified file. If no output file is provided, it defaults to `output.log`.

```sh
redex [options] <command>
```

### Options

- `--help`: Show help message and exit.
- `-o, --output FILE`: Specify output file name and location (default: `output.log`).

### Examples

```sh
redex "ls -la"
```
This will execute `ls -la` and save all output to `output.log`.

```sh
redex -o custom_output.log "echo Hello, World!"
```
This will execute `echo Hello, World!` and save the output to `custom_output.log`.





