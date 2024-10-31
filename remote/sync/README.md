# sync_remote.sh

`sync_remote.sh` is a flexible, bidirectional file synchronization script that enables efficient syncing between a local directory and a remote server. This script can synchronize changes in both directions, one-way, or based on user-defined intervals, making it adaptable for various use cases, such as development or backup.

## Features
- **Bidirectional Synchronization**: Sync changes between local and remote directories.
- **One-way Synchronization**: Sync only from local to remote or remote to local.
- **Customizable Sync Interval**: Set a custom interval for sync checks (default is 10 seconds).
- **Debugging**: Enable detailed logging to help with troubleshooting.
- **Efficient Monitoring**: Uses checksum comparison to detect changes, minimizing resource usage.

## Requirements
- `rsync` installed on both local and remote machines.
- `SSH` access to the remote machine.
- `md5sum` on both local and remote machines for checksum calculations.

## Usage
### Basic Command Structure
```bash
./sync_remote.sh [OPTIONS] REMOTE_USER REMOTE_SERVER REMOTE_PATH LOCAL_PATH
```
### Parameters
- `REMOTE_USER`: Username for SSH access to the remote server.
- `REMOTE_SERVER`: Address of the remote server.
- `REMOTE_PATH`: Path on the remote server for synchronization.
- `LOCAL_PATH`: Local path to synchronize with the remote directory.

### Options
| Option              | Description                                                                                                                                             |
|---------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-h`, `--help`      | Display the help menu with usage instructions.                                                                                                         |
| `-i`, `--interval`  | Set the interval (in seconds) for sync checks. Default is 10 seconds.                                                                                  |
| `-d`, `--direction` | Set the sync direction. Options: `both` (default), `local-to-remote`, or `remote-to-local`.                                                            |
| `--debug`           | Enable detailed logging to show the internal process flow, such as checksum calculations, sync actions, and interval waits.                            |

## Examples

### 1. Bidirectional Sync with Default Interval
Synchronize changes in both directions with a 10-second interval.
```bash
./sync_remote.sh melashri gpu-server /home/melashri/inference-engine /home/melashri/projects/inference-engine
```

### 2. One-Way Sync: Local to Remote
Sync only from the local directory to the remote directory, with a 5-second interval.
```bash
./sync_remote.sh -i 5 -d local-to-remote melashri gpu-server /home/melashri/inference-engine /home/melashri/projects/inference-engine
```

### 3. One-Way Sync: Remote to Local
Sync only from the remote directory to the local directory, with the default 10-second interval.
```bash
./sync_remote.sh -d remote-to-local melashri gpu-server /home/melashri/inference-engine /home/melashri/projects/inference-engine
```

### 4. Debugging Mode
Enable `--debug` to see detailed information about each step, including checksum calculations and sync actions.
```bash
./sync_remote.sh --debug -i 15 -d both melashri gpu-server /home/melashri/inference-engine /home/melashri/projects/inference-engine
```

## Output Explanation

The script logs various levels of information to indicate its process:

- **[INFO]**: General status updates, such as sync actions.
- **[ERROR]**: Errors encountered, such as invalid paths or arguments.
- **[DEBUG]**: (Only in debug mode) Detailed steps, including checksum generation and sync operations.

### Sample Output
```plaintext
[INFO] Performing initial sync from melashri@gpu-server:/home/melashri/inference-engine to /home/melashri/projects/inference-engine
[INFO] Syncing changes from local to remote
[DEBUG] Executing rsync from '/home/melashri/projects/inference-engine' to 'melashri@gpu-server:/home/melashri/inference-engine'
[INFO] No checksum mismatch detected. No sync needed.
[DEBUG] Waiting 10 seconds before the next sync check.
```

This output provides clarity on each sync operation and shows the user whether any action was required during each check interval.

## Best Practices

- Use shorter intervals (e.g., 5 seconds) for active development environments where changes occur frequently.
- For less frequent updates, increase the interval to reduce resource usage.
- For troubleshooting, run the script with the `--debug` flag to monitor the flow and spot potential issues.

