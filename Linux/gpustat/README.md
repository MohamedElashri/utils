# GPU Monitoring Tool

A Poor's man command-line tool for monitoring NVIDIA GPU stats and processes.

## Installation

1. Download the script:
   ```
   curl -o ~/.local/bin/gpustat https://github.com/MohamedElashri/utils/raw/refs/heads/main/linux/gpustat/gpustat
   ```

2. Make the script executable:
   ```
   chmod +x ~/.local/bin/gpustat
   ```

3. Ensure `~/.local/bin` is in your PATH. Add this line to your `~/.bashrc` or `~/.zshrc`:
   ```
   export PATH="$HOME/.local/bin:$PATH"
   ```

4. Reload your shell configuration:
   ```
   source ~/.bashrc  # or source ~/.zshrc
   ```

## Usage

Run the tool with:

```
gpustat [options]
```

Options:
- `-h, --help`: Show help message and exit.
- `-N, --no-color`: Suppress colored output.
- `-w, --watch [INTERVAL]`: Run in watch mode, updating every INTERVAL seconds (default: 1).
- `-d, --debug`: Show debug information.
- `-p, --process`: Show processes running on GPUs.
- `-g, --gpus GPUS`: Select specific GPUs to monitor (comma-separated indices).
- `-s, --sort FIELD`: Sort GPUs by FIELD (memory, temperature, or utilization).
- `-r, --reverse`: Reverse the sort order.

## Examples

1. Monitor all GPUs, updating every 2 seconds:
   ```
   gpustat -w 2
   ```

2. Show GPU stats and processes for GPUs 0 and 1:
   ```
   gpustat -p -g 0,1
   ```

3. Sort GPUs by memory usage in descending order:
   ```
   gpustat -s memory
   ```

4. Monitor GPUs 1 and 2, sort by temperature in ascending order, update every 5 seconds:
   ```
   gpustat -g 1,2 -s temperature -r -w 5
   ```
