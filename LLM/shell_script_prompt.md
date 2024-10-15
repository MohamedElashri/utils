# Shell Script Best Practices

Here's a set of best practices to make your shell scripts more robust, user-friendly, and maintainable. The script should include error handling, colorful logging, platform-specific adaptations, modularity, and detailed instructions to help ensure a consistent experience across Unix/BSD systems.

## Key Practices to Implement

### 1. Comprehensive Error Handling
Use the following statement to add robust error handling:

```bash
set -euo pipefail
```
- `-e`: Exit on command errors.
- `-u`: Treat unset variables as an error.
- `-o pipefail`: Catch errors in pipelines.

### 2. Color-Coded Logging Functions
Color-coded logging makes the script output more readable by highlighting important messages.

- **Log Functions**:
  - `log_info()`: Should display informational messages in green.
  - `log_warning()`: Should display warnings in yellow.
  - `log_error()`: Should display error messages in red and output to standard error (`stderr`).

- **Example**:

  ```bash
  green="\033[0;32m"
  yellow="\033[1;33m"
  red="\033[0;31m"
  nc="\033[0m" # No Color

  log_info() {
    echo -e "${green}[INFO]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1"
  }

  log_warning() {
    echo -e "${yellow}[WARNING]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1"
  }

  log_error() {
    echo -e "${red}[ERROR]${nc} $(date '+%Y-%m-%d %H:%M:%S') - $1" >&2
  }
  ```

### 3. Progress Reporting with Command Execution
To add transparency, include a function that prints commands before executing them:

- **Example**:

  ```bash
  print_and_execute() {
    echo -e "${green}+ $@${nc}" >&2
    "$@"
  }
  ```

### 4. Platform-Specific Adaptations
The script should adapt to different operating systems to ensure compatibility.

- **Timeout Command Adaptation**:

  ```bash
  TIMEOUT=""
  if [ "$(uname -s)" == "Linux" ]; then
    TIMEOUT="timeout -v"
  elif [ "$(uname -s)" == "Darwin" ]; then
    if [ -x "$(command -v gtimeout)" ]; then
      TIMEOUT="gtimeout -v"
    else
      log_warning "gtimeout not available. Install with 'brew install coreutils'."
    fi
  fi
  ```

### 5. Usage Instructions
Include a `usage` function to provide help messages when requested.

- **Example**:

  ```bash
  usage() {
    cat << EOF
  Usage: $(basename "$0") [options]

  Options:
    --help                Show this help message and exit.
    ...

  Examples:
    $(basename "$0") <command>
  EOF
  }
  ```

### 6. Argument Validation
Make sure to validate arguments and provide clear error messages if none are provided.

- **Example**:

  ```bash
  if [[ $# -eq 0 ]]; then
    log_error "No arguments provided. Use --help for usage instructions."
    exit 1
  fi
  ```

### 7. Timestamped File Outputs
Add timestamps to output files to avoid overwriting them and ensure uniqueness.

- **Example**:

  ```bash
  filetimestamp=$(date +"%Y%m%d%H%M%S")
  output_file="output_${filetimestamp}.log"
  ```

### 8. Comments and Clear Naming
Use descriptive variable and function names, and include comments to explain complex sections of the code. This helps make the script more understandable and maintainable for others or for future reference.

### 9. Modularity
Organize the script into functions to improve readability and maintainability. Each function should handle a specific task, making it easier to debug and extend.

### 10. Enhanced User Experience
- Handle errors gracefully without exposing unnecessary technical details.
- Avoid assumptions about the user's environment; check for required tools and dependencies, and inform the user if they're missing.

### 11. Example Command Execution
Use `print_and_execute` to report progress and handle output effectively.

- **Example**:

  ```bash
  print_and_execute echo "This is a sample command." > "$output_file"
  log_info "Script completed successfully. Output saved to $output_file."
  ```
