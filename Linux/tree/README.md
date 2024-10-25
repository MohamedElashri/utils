# Poor's Man Tree Command

This ia my poor's man implementation of main functions (to me) of the tree command. because sometimes they are not there (looking at you CERN's LHCb GPU Development nodes)

## Installation
To install the tree command clone on your system, follow these steps:

1. **Download the Script**: Save the provided script to a file named `tree` in a suitable location on your system.

2. **Make the Script Executable**: Use the `chmod` command to make the script executable:
   ```bash
   chmod +x tree
   ```

3. **Move to Local Bin**: Move the script to `~/.local/bin` to make it easily accessible from anywhere in your terminal. If `~/.local/bin` does not exist, you can create it:
   ```bash
   mkdir -p ~/.local/bin
   mv tree ~/.local/bin/tree
   ```

4. **Update PATH**: Ensure `~/.local/bin` is included in your `PATH` variable by adding the following line to your `.bashrc` or `.zshrc`:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```
   After adding the line, reload your profile:
   ```bash
   source ~/.bashrc
   ```

   or if it is zsh
   ```bash
   source ~/.zshrc
   ```



## Usage Examples
This tree command clone allows you to visualize the directory structure with various filtering options and additional features.

### Basic Usage
To display the directory structure for the current directory:
```bash
tree
```

### Set Maximum Display Depth
To set the maximum depth of the directory tree to 2 levels:
```bash
tree -L 2 /path/to/directory
```

### Include Hidden Files
To include hidden files in the output:
```bash
tree -a
```
Or, equivalently:
```bash
tree --all
```

### Redirect Output to a File
To redirect the output to a specified file:
```bash
tree -o output.txt
```

### Filter by File Extension
To only display files with a specific extension, such as `.txt`:
```bash
tree --ext txt
```

### Exclude Files or Directories by Pattern
To exclude files or directories matching a specified regex pattern, such as `.log` files:
```bash
tree -e '.*\.log'
```
Or, equivalently:
```bash
tree --exclude '.*\.log'
```

### Include Only Files or Directories by Pattern
To include only files or directories that match a specific regex pattern, such as directories containing "data":
```bash
tree -i '.*data.*'
```
Or, equivalently:
```bash
tree --include '.*data.*'
```

### Combined Usage
To display a tree with hidden files, excluding `.log` files, and with a maximum depth of 3:
```bash
tree -a -L 3 -e '.*\.log'
```

### Display Help
To view the available options and usage instructions:
```bash
tree -h
```
Or, equivalently:
```bash
tree --help
```

## Summary of Options
- `-L <depth>`: Set the maximum display depth of the directory tree.
- `-a, --all`: Include hidden files in the output.
- `-o <file>`: Redirect output to the specified file.
- `--ext <extension>`: Filter files by the specified extension.
- `-e, --exclude <pattern>`: Exclude files or directories matching the specified regex pattern.
- `-i, --include <pattern>`: Include only files or directories matching the specified regex pattern.
- `-h, --help`: Show the help message and exit.

