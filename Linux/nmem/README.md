# nmem: Memory Usage Tool

`nmem` is a poor's man script to display memory usage information in a human-readable table format, similar to the `free` command. 
It can show data in different units like bytes, kilobytes, megabytes, and gigabytes, and can be continuously updated in watch mode.

## Installation

1. Copy the script to your local bin directory:
   ```sh
   mkdir -p ~/.local/bin
   cp nmem ~/.local/bin/nmem
   chmod +x ~/.local/bin/nmem
   ```

2. Add `~/.local/bin` to your PATH if it isn't already:
   ```sh
   echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

## Usage

Run the `nmem` command with the desired options:

```sh
nmem [OPTION]...
```

### Options

- `-b`        Show output in bytes
- `-k`        Show output in kilobytes
- `-m`        Show output in megabytes
- `-g`        Show output in gigabytes
- `--help`    Display help information and exit
- `--watch`   Continuously update the display every second

### Example

To display memory usage in megabytes and continuously update:

```sh
nmem -m --watch
```

Without any options, `nmem` defaults to displaying memory in a human-readable format.

