# txm - A Simple tmux and screen Wrapper

`txm` is a wrapper script for `tmux` and `screen` that provides a more human-friendly command interface to manage terminal sessions. It allows users to easily create, attach, detach, delete sessions, and manage windows and panes in `tmux`. If `tmux` is not installed, it will automatically fall back to using `screen`. Note that not all features are available in `screen`, and some commands require `tmux`.

## Installation

To install `txm`, simply place the script in your `$HOME/.local/bin` directory, or any directory in your `$PATH`.

```bash
mkdir -p $HOME/.local/bin
cp txm $HOME/.local/bin/txm
chmod +x $HOME/.local/bin/txm
```

Ensure `$HOME/.local/bin` is in your `$PATH` for easy access.

## Usage

Below is a summary of all the commands supported by `txm`:

| Command                                                                  | Description                                                         | Works With      |
| ------------------------------------------------------------------------ | ------------------------------------------------------------------- | --------------- |
| `create [session_name]`                                                  | Create a new `tmux` or `screen` session                             | tmux, screen    |
| `list`                                                                   | List all `tmux` or `screen` sessions                                | tmux, screen    |
| `attach [session_name]`                                                  | Attach to a `tmux` or `screen` session                              | tmux, screen    |
| `detach`                                                                 | Detach from the current `tmux` session (not supported for `screen`) | tmux            |
| `delete [session_name]`                                                  | Delete a `tmux` or `screen` session                                 | tmux, screen    |
| `new-window [session_name] [name]`                                       | Create a new window in a `tmux` session                             | tmux            |
| `list-windows [session_name]`                                            | List windows in a `tmux` session                                    | tmux            |
| `kill-window [session_name] [name]`                                      | Kill a window in a `tmux` session                                   | tmux            |
| `rename-session [session_name] [new_name]`                               | Rename an existing `tmux` session                                   | tmux            |
| `rename-window [session_name] [window_index] [new_name]`                 | Rename a window in a `tmux` session                                 | tmux            |
| `split-window [session_name] [window_index] [vertical/horizontal]`       | Split a pane in a `tmux` window                                     | tmux            |
| `list-panes [session_name] [window_index]`                               | List all panes in a `tmux` window                                   | tmux            |
| `kill-pane [session_name] [window_index] [pane_index]`                   | Kill a specific pane in a `tmux` window                             | tmux            |
| `move-window [session_name] [window_index] [new_session]`                | Move a window to another `tmux` session                             | tmux            |
| `swap-window [session_name] [window_index_1] [window_index_2]`           | Swap two windows in a `tmux` session                                | tmux            |
| `resize-pane [session_name] [window_index] [pane_index] [resize_option]` | Resize a pane in a `tmux` window                                    | tmux            |
| `send-keys [session_name] [window_index] [pane_index] [keys]`            | Send keys to a pane in a `tmux` window                              | tmux            |

## Examples

### Create a New Session
To create a new session called `my_session`:
```bash
txm create my_session
```

### List Sessions
To list all sessions:
```bash
txm list
```

### Attach to a Session
To attach to an existing session named `my_session`:
```bash
txm attach my_session
```

### Detach from a Session
To detach from the current session (works only in `tmux`):
```bash
txm detach
```

### Delete a Session
To delete a session named `my_session`:
```bash
txm delete my_session
```

### Create a New Window
To create a new window named `my_window` in the `my_session`:
```bash
txm new-window my_session my_window
```

### List Windows
To list all windows in `my_session`:
```bash
txm list-windows my_session
```

### Split a Window Pane
To split a window pane vertically in `my_session` at window index `1`:
```bash
txm split-window my_session 1 vertical
```

### Send Keys to a Pane
To send the keys `ls -la` to pane index `0` in window `1` of `my_session`:
```bash
txm send-keys my_session 1 0 "ls -la"
```
