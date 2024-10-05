# History Wrapper Script

This `history` wrapper enhances the default shell history command with a set of powerful features to help manage your command history more effectively. This README provides a detailed explanation of each function, along with examples to demonstrate how to use them.


## Installation

To use this history wrapper, add the function definition to your `.bashrc` or `.zshrc` file. Then source the file to make it available in your current terminal session:

```sh
source ~/.bashrc
```

or

```sh
source ~/.zshrc
```

## Features & Usage

### 1. Show Last `n` Entries
Display the last `n` entries in history.

**Usage:**
```sh
history <n>
```
**Example:**
```sh
history 20  # Shows the last 20 entries.
```

### 2. Search for a Keyword in History
Search the history for commands containing a specific keyword.

**Usage:**
```sh
history search <keyword>
```
**Example:**
```sh
history search git  # Shows all commands containing 'git'.
```

### 3. Run a Specific Command by ID
Run a specific command from history by its ID.

**Usage:**
```sh
history run <ID>
```
**Example:**
```sh
history run 125  # Runs the command with ID 125 from the history.
```

### 4. Delete a Specific Command from History
Delete a command from history by its ID.

**Usage:**
```sh
history delete <ID>
```
**Example:**
```sh
history delete 100  # Deletes the command with ID 100.
```

### 5. Clear History
Clear the entire command history.

**Usage:**
```sh
history clear
```
**Example:**
```sh
history clear  # Clears the entire command history.
```

### 6. Show Unique Commands
Display only the unique commands from the history to remove redundant entries.

**Usage:**
```sh
history unique
```
**Example:**
```sh
history unique  # Shows unique commands used in history.
```

### 7. Export History to a File
Save the current command history to a file for backup or sharing.

**Usage:**
```sh
history export <filename>
```
**Example:**
```sh
history export my_history.txt  # Exports history to 'my_history.txt'.
```

### 8. Import History from a File
Import commands from a file and add them to the current history.

**Usage:**
```sh
history import <filename>
```
**Example:**
```sh
history import my_history.txt  # Imports history from 'my_history.txt'.
```

### 9. Show Command Usage Statistics
Display statistics on command usage, showing the frequency of each command.

**Usage:**
```sh
history stats
```
**Example:**
```sh
history stats  # Shows command usage statistics.
```

### 10. Interactive Search with `fzf`
Search the command history interactively using `fzf`.

**Usage:**
```sh
history interactive
```
**Example:**
```sh
history interactive  # Opens an interactive search for history commands using 'fzf'.
```

### 11. Show History in a Specific Range
View commands from a specific range of history IDs.

**Usage:**
```sh
history range <start_ID> <end_ID>
```
**Example:**
```sh
history range 50 100  # Shows commands from ID 50 to ID 100.
```

### 12. Re-run the Last Command
Re-run the last command executed before the most recent one.

**Usage:**
```sh
history last
```
**Example:**
```sh
history last  # Runs the last command executed.
```

### 13. Blacklist Commands from History
Prevent specific commands from being saved in the history.

**Usage:**
```sh
history blacklist <command>
```
**Example:**
```sh
history blacklist ssh  # Prevents 'ssh' commands from being saved in history.
```

### 14. Mark a Command as Favorite
Mark a command as a favorite by its ID, and save it for later reference.

**Usage:**
```sh
history favorite <ID>
```
**Example:**
```sh
history favorite 345  # Marks command with ID 345 as a favorite.
```

### 15. Show Favorite Commands
Display all the commands that have been marked as favorites.

**Usage:**
```sh
history showfavorites
```
**Example:**
```sh
history showfavorites  # Shows all favorite commands.
```

### 16. Backup History with Timestamp
Create a backup of the history with a timestamp for later reference.

**Usage:**
```sh
history backup
```
**Example:**
```sh
history backup  # Backs up the history to a timestamped file.
```

### 17. Restore Last Deleted Command
Restore the last deleted command from history.

**Usage:**
```sh
history restorelast
```
**Example:**
```sh
history restorelast  # Restores the last deleted command.
```

### 18. Show the Most Frequently Used Commands
Display a list of the most frequently used commands from history.

**Usage:**
```sh
history mostused
```
**Example:**
```sh
history mostused  # Shows the top 10 most frequently used commands.
```

### 19. Save Current Session History
Save the current session history to a specified file.

**Usage:**
```sh
history savesession <filename>
```
**Example:**
```sh
history savesession session_history.txt  # Saves the current session to 'session_history.txt'.
```

### 20. Restore Session History
Restore history from a saved file to the current session.

**Usage:**
```sh
history restoresession <filename>
```
**Example:**
```sh
history restoresession session_history.txt  # Restores history from 'session_history.txt'.
```

