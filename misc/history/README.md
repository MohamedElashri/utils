# `hist` - Enhanced Shell History Manager

`hist` is a cross-shell command history enhancement tool designed for both **Bash** and **Zsh**. It expands the built-in `history` functionality with powerful features for managing, searching, and interacting with your shell command history.  

All data is stored neatly under:

```
~/.config/.hist
```

This ensures your home directory remains clean.

---

## Installation

1. Save the `hist` script to:
```sh
~/.local/bin/hist
```

2. Make it executable:
```sh
chmod +x ~/.local/bin/hist
```

3. Ensure `~/.local/bin` is in your `$PATH` (add to `.bashrc` or `.zshrc` if needed):
```sh
export PATH="$HOME/.local/bin:$PATH"
```

4. Run:
```sh
hist --help
```

---

## Features & Usage

### 1. Show Last `n` Entries
Display the last `n` commands from history.

**Usage:**
```sh
hist <n>
```
**Example:**
```sh
hist 20
```

---

### 2. Search History
Search for commands containing a specific keyword.

**Usage:**
```sh
hist search <keyword>
```
**Example:**
```sh
hist search git
```

---

### 3. Run Command by ID
Run a command directly from its history ID.

**Usage:**
```sh
hist run <ID>
```
**Example:**
```sh
hist run 125
```

---

### 4. Delete Command by ID
Remove a command from history (can be restored).

**Usage:**
```sh
hist delete <ID>
```
**Example:**
```sh
hist delete 100
```

---

### 5. Clear Entire History
**Usage:**
```sh
hist clear
```

---

### 6. Show Unique Commands
Filter out duplicate commands.

**Usage:**
```sh
hist unique
```

---

### 7. Backup History
Save history to a timestamped file.

**Usage:**
```sh
hist backup
```

---

### 8. Restore Last Deleted Command
Undo the most recent deletion.

**Usage:**
```sh
hist restorelast
```

---

### 9. Favorite Command by ID
Mark a command as a "favorite" for easy recall.

**Usage:**
```sh
hist favorite <ID>
```

---

### 10. Show Favorites
List all saved favorites.

**Usage:**
```sh
hist showfavorites
```

---

### 11. Blacklist Commands
Prevent certain commands from being saved in history.

**Usage:**
```sh
hist blacklist <command>
```
Example:
```sh
hist blacklist ssh
```
This will block all future `ssh` commands from being saved.

---

### 12. Interactive Fuzzy Search
Search history interactively using `fzf` (must be installed).

**Usage:**
```sh
hist interactive
```

---

### 13. Show History in Range
View commands between two history IDs.

**Usage:**
```sh
hist range <start> <end>
```

---

### 14. Show Most Used Commands
See the top 10 most frequently used commands.

**Usage:**
```sh
hist mostused
```

---

### 15. Save Session History
Save current session history to a specific file.

**Usage:**
```sh
hist savesession <filename>
```

---

### 16. Restore Session History
Load a saved session into current shell history.

**Usage:**
```sh
hist restoresession <filename>
```

---

## How It Works

- All data (backups, favorites, blacklist, deleted commands log) is stored in:
    ```
    ~/.config/.hist/
    ```
- No commands are `eval`ed directly — all are safely executed in a **subshell**.
- Both **Bash** and **Zsh** are supported.
- `hist` works by **reading directly from your live shell history**, so it always shows what your shell knows — no outdated caches.
- Blacklisted commands never enter history at all.

---

## Data Storage Structure

```text
~/.config/.hist/
├── backups/           # All backups stored here
├── blacklist          # Commands to exclude from history
├── favorites          # Saved favorite commands
├── deleted.log        # Recently deleted commands (for restore)
```

---

## Example Workflow

```sh
# Search history for all git commands
hist search git

# Run command #123 from history
hist run 123

# Delete a specific command from history
hist delete 200

# Restore the last deleted command
hist restorelast

# Backup current history
hist backup

# Mark a useful command as favorite
hist favorite 300

# View all favorites
hist showfavorites

# Blacklist 'ls' (stop saving it to history)
hist blacklist ls

# Perform interactive fuzzy search using fzf
hist interactive
```

---

## Compatibility

✅ Bash 4.x+  
✅ Zsh 5.x+  
✅ Works on Linux, macOS, and WSL.

---

## Requirements

- `fzf` (for `hist interactive`)
- Standard `awk`, `grep`, `sed`, and `date` utilities

---

## License
MIT License. You are free to use, modify, and distribute.

---

## Contributing
Contributions are welcome. If you have an idea for a new feature, feel free to submit a pull request.

