
# Redex

**Redex** is a versatile command wrapper script designed to execute commands and capture all output (both `stdout` and `stderr`) in a log file. It offers comprehensive error handling, color-coded logging for enhanced visibility, and is compatible with both `bash` and `zsh` environments.

## Installation

To install **Redex**, clone the repository and move the script to your preferred location. By default, we assume it is installed at `~/.local/bin/redex`:

```sh
mkdir -p ~/.local/bin
cp redex ~/.local/bin/redex
chmod +x ~/.local/bin/redex
```

Ensure `~/.local/bin` is included in your system's `PATH`. Add this line to your `~/.bashrc` or `~/.zshrc`:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Reload your shell configuration:

```sh
source ~/.bashrc # or source ~/.zshrc
```

## Usage

Run **Redex** with any command you wish to execute, and the script will log all output to a specified file. If no output file is provided, it defaults to `output.log`.

```sh
redex [options] -- <command>
```

### Options

- `--help`: Show the help message and exit.
- `-l, --log-output FILE`: Specify the log output file name and location (default: `output.log`).

### Examples

```sh
redex -- "ls -la"
```

This example will execute `ls -la` and save the output to `output.log`.

```sh
redex -l custom_log_output.log -- "echo Hello, World!"
```

This will execute `echo Hello, World!` and save the output to `custom_log_output.log`.

